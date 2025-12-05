// supabase/functions/payment-callback/index.ts
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  )

  try {
    const contentType = req.headers.get('content-type') || ''
    let data: any

    // Parse based on content type (Duitku sends form-urlencoded, Flip sends JSON)
    if (contentType.includes('application/x-www-form-urlencoded')) {
      const formData = await req.formData()
      data = Object.fromEntries(formData.entries())
    } else {
      data = await req.json()
    }

    const merchantOrderId = data.merchantOrderId || data.merchant_order_id || data.bill_link_id

    if (!merchantOrderId) {
      return new Response('Missing order ID', { status: 400 })
    }

    // Determine if it's subscription or envelope based on prefix
    const isEnvelope = merchantOrderId.startsWith('ENV-')
    const table = isEnvelope ? 'envelope_payments' : 'orders'

    // Verify signature for Duitku
    if (data.signature) {
      const DUITKU_API_KEY = Deno.env.get('DUITKU_API_KEY')!
      const DUITKU_MERCHANT_CODE = Deno.env.get('DUITKU_MERCHANT_CODE')!

      // Verify signature logic...
    }

    // Determine status
    const resultCode = data.resultCode || data.status
    const isSuccess = resultCode === '00' || resultCode === 'SUCCESSFUL'
    const status = isSuccess ? 'success' : 'failed'

    // Update payment status
    const { data: payment, error } = await supabase
      .from(table)
      .update({
        status,
        gateway_reference: data.reference || data.bill_link_id,
        paid_at: isSuccess ? new Date().toISOString() : null,
      })
      .eq('merchant_order_id', merchantOrderId)
      .select('*, invitations(*)')
      .single()

    if (error) throw error

    // If subscription payment success, update user subscription
    if (!isEnvelope && isSuccess && payment) {
      const { data: order } = await supabase
        .from('orders')
        .select('user_id, package_type')
        .eq('merchant_order_id', merchantOrderId)
        .single()

      if (order) {
        // Calculate subscription expiry based on package
        const expiryMonths = {
          sakinah: 6,
          mawaddah: 12,
          warahmah: 120, // 10 years (lifetime-ish)
        }

        const expiresAt = new Date()
        expiresAt.setMonth(expiresAt.getMonth() + (expiryMonths[order.package_type] || 6))

        await supabase
          .from('users')
          .update({
            subscription_tier: order.package_type,
            subscription_expires_at: expiresAt.toISOString(),
          })
          .eq('id', order.user_id)
      }
    }

    // Send notification via WhatsApp if envelope payment success
    if (isEnvelope && isSuccess && payment?.invitations) {
      const { data: owner } = await supabase
        .from('users')
        .select('phone')
        .eq('id', payment.invitations.user_id)
        .single()

      if (owner?.phone) {
        // Call WhatsApp edge function
        await fetch(`${Deno.env.get('SUPABASE_URL')}/functions/v1/send-whatsapp`, {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')}`,
          },
          body: JSON.stringify({
            phone: owner.phone,
            message: `🎉 Amplop digital diterima!\n\nDari: ${payment.is_anonymous ? 'Anonim' : payment.guest_name}\nJumlah: Rp${payment.amount.toLocaleString('id-ID')}\nPesan: ${payment.message || '-'}`,
          }),
        })
      }
    }

    return new Response('OK', { status: 200 })

  } catch (error) {
    console.error('Callback error:', error)
    return new Response('Error', { status: 500 })
  }
})
