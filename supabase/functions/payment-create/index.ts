// supabase/functions/payment-create/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'
import { crypto } from 'https://deno.land/std@0.177.0/crypto/mod.ts'
import { encode as hexEncode } from 'https://deno.land/std@0.177.0/encoding/hex.ts'

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
}

// Duitku Configuration
const DUITKU_MERCHANT_CODE = Deno.env.get('DUITKU_MERCHANT_CODE')!
const DUITKU_API_KEY = Deno.env.get('DUITKU_API_KEY')!
const DUITKU_BASE_URL = Deno.env.get('DUITKU_ENV') === 'production'
  ? 'https://passport.duitku.com'
  : 'https://sandbox.duitku.com'

// Flip Configuration
const FLIP_SECRET_KEY = Deno.env.get('FLIP_SECRET_KEY')!
const FLIP_BASE_URL = Deno.env.get('FLIP_ENV') === 'production'
  ? 'https://bigflip.id/api/v3'
  : 'https://bigflip.id/big_sandbox_api/v3'

interface PaymentRequest {
  type: 'subscription' | 'envelope'
  amount: number
  payment_method: string
  payment_channel: string
  gateway: 'duitku' | 'flip'
  customer_name: string
  customer_email: string
  customer_phone?: string
  package_type?: string
  addons?: string[]
  invitation_id?: string
  message?: string
  is_anonymous?: boolean
  user_id?: string
}

async function md5(message: string): Promise<string> {
  const encoder = new TextEncoder()
  const data = encoder.encode(message)
  const hashBuffer = await crypto.subtle.digest('MD5', data)
  return new TextDecoder().decode(hexEncode(new Uint8Array(hashBuffer)))
}

async function createDuitkuPayment(body: PaymentRequest, merchantOrderId: string) {
  const signatureString = `${DUITKU_MERCHANT_CODE}${merchantOrderId}${body.amount}${DUITKU_API_KEY}`
  const signature = await md5(signatureString)

  const payload = {
    merchantCode: DUITKU_MERCHANT_CODE,
    paymentAmount: body.amount,
    paymentMethod: body.payment_channel,
    merchantOrderId: merchantOrderId,
    productDetails: body.type === 'subscription'
      ? `Paket ${body.package_type} - NikahKit`
      : 'Amplop Digital - NikahKit',
    customerVaName: body.customer_name.substring(0, 20),
    email: body.customer_email,
    phoneNumber: body.customer_phone || '',
    callbackUrl: `${Deno.env.get('SUPABASE_URL')}/functions/v1/payment-callback`,
    returnUrl: `${Deno.env.get('APP_URL')}/payment/status/${merchantOrderId}`,
    signature: signature,
    expiryPeriod: 1440, // 24 hours in minutes
  }

  const response = await fetch(`${DUITKU_BASE_URL}/webapi/api/merchant/v2/inquiry`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  })

  return await response.json()
}

async function createFlipPayment(body: PaymentRequest, merchantOrderId: string) {
  const expiredDate = new Date(Date.now() + 24 * 60 * 60 * 1000)
    .toISOString()
    .split('T')[0]

  const payload = new URLSearchParams({
    title: body.type === 'subscription'
      ? `Paket ${body.package_type}`
      : 'Amplop Digital',
    amount: body.amount.toString(),
    type: 'SINGLE',
    expired_date: expiredDate,
    redirect_url: `${Deno.env.get('APP_URL')}/payment/status/${merchantOrderId}`,
    is_address_required: '0',
    is_phone_number_required: '0',
    step: '2',
    sender_name: body.customer_name,
    sender_email: body.customer_email,
    sender_phone_number: body.customer_phone || '',
  })

  const response = await fetch(`${FLIP_BASE_URL}/pwf/bill`, {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${btoa(FLIP_SECRET_KEY + ':')}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: payload,
  })

  return await response.json()
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders })
  }

  try {
    const supabase = createClient(
      Deno.env.get('SUPABASE_URL')!,
      Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
    )

    const body: PaymentRequest = await req.json()

    // Generate unique order ID
    const timestamp = Date.now()
    const random = crypto.randomUUID().slice(0, 8).toUpperCase()
    const prefix = body.type === 'subscription' ? 'SUB' : 'ENV'
    const merchantOrderId = `${prefix}-${timestamp}-${random}`

    let gatewayResult: any

    // Create payment based on gateway
    if (body.gateway === 'duitku') {
      gatewayResult = await createDuitkuPayment(body, merchantOrderId)

      if (gatewayResult.statusCode !== '00') {
        throw new Error(gatewayResult.statusMessage || 'Duitku payment failed')
      }
    } else {
      gatewayResult = await createFlipPayment(body, merchantOrderId)

      if (gatewayResult.error) {
        throw new Error(gatewayResult.error.message || 'Flip payment failed')
      }
    }

    // Save to database
    const paymentData = {
      merchant_order_id: merchantOrderId,
      payment_gateway: body.gateway,
      payment_method: body.payment_method,
      payment_channel: body.payment_channel,
      amount: body.amount,
      status: 'pending',
      expired_at: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
      ...(body.gateway === 'duitku' ? {
        gateway_reference: gatewayResult.reference,
        payment_url: gatewayResult.paymentUrl,
        va_number: gatewayResult.vaNumber,
        qr_string: gatewayResult.qrString,
      } : {
        gateway_reference: gatewayResult.link_id,
        payment_url: gatewayResult.link_url,
      }),
    }

    if (body.type === 'envelope') {
      await supabase.from('envelope_payments').insert({
        ...paymentData,
        invitation_id: body.invitation_id,
        guest_name: body.customer_name,
        message: body.message,
        is_anonymous: body.is_anonymous,
      })
    } else {
      await supabase.from('orders').insert({
        ...paymentData,
        user_id: body.user_id,
        invitation_id: body.invitation_id,
        package_type: body.package_type,
        addons: body.addons,
        base_price: body.amount,
        total_amount: body.amount,
      })
    }

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          merchant_order_id: merchantOrderId,
          payment_url: body.gateway === 'duitku'
            ? gatewayResult.paymentUrl
            : gatewayResult.link_url,
          va_number: gatewayResult.vaNumber,
          qr_string: gatewayResult.qrString,
          amount: body.amount,
          expired_at: paymentData.expired_at,
        },
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )

  } catch (error) {
    return new Response(
      JSON.stringify({ success: false, error: error.message }),
      { status: 400, headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
    )
  }
})
