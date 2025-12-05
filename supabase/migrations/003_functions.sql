-- supabase/migrations/003_functions.sql

-- Get invitation statistics
CREATE OR REPLACE FUNCTION get_invitation_stats(p_invitation_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_guests', (SELECT COUNT(*) FROM guests WHERE invitation_id = p_invitation_id),
        'total_attending', (SELECT COUNT(*) FROM guests WHERE invitation_id = p_invitation_id AND rsvp_status = 'attending'),
        'total_not_attending', (SELECT COUNT(*) FROM guests WHERE invitation_id = p_invitation_id AND rsvp_status = 'not_attending'),
        'total_pending', (SELECT COUNT(*) FROM guests WHERE invitation_id = p_invitation_id AND rsvp_status IS NULL),
        'total_checked_in', (SELECT COUNT(*) FROM guests WHERE invitation_id = p_invitation_id AND checked_in_at IS NOT NULL),
        'total_messages', (SELECT COUNT(*) FROM guest_messages WHERE invitation_id = p_invitation_id),
        'total_envelope', (SELECT COALESCE(SUM(amount), 0) FROM envelope_payments WHERE invitation_id = p_invitation_id AND status = 'success'),
        'view_count', (SELECT view_count FROM invitations WHERE id = p_invitation_id)
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Search guests with full-text search
CREATE OR REPLACE FUNCTION search_guests(
    p_invitation_id UUID,
    p_query TEXT
)
RETURNS SETOF guests AS $$
BEGIN
    RETURN QUERY
    SELECT *
    FROM guests
    WHERE invitation_id = p_invitation_id
    AND (
        name ILIKE '%' || p_query || '%'
        OR phone ILIKE '%' || p_query || '%'
        OR email ILIKE '%' || p_query || '%'
        OR group_name ILIKE '%' || p_query || '%'
    )
    ORDER BY name ASC;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Check-in guest
CREATE OR REPLACE FUNCTION check_in_guest(
    p_guest_id UUID,
    p_checked_in_by UUID
)
RETURNS guests AS $$
DECLARE
    result guests;
BEGIN
    UPDATE guests
    SET
        checked_in_at = NOW(),
        checked_in_by = p_checked_in_by
    WHERE id = p_guest_id
    AND checked_in_at IS NULL
    RETURNING * INTO result;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Guest not found or already checked in';
    END IF;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Increment view count
CREATE OR REPLACE FUNCTION increment_view_count(p_invitation_id UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE invitations
    SET view_count = view_count + 1
    WHERE id = p_invitation_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Get dashboard summary for user
CREATE OR REPLACE FUNCTION get_user_dashboard(p_user_id UUID)
RETURNS JSON AS $$
DECLARE
    result JSON;
BEGIN
    SELECT json_build_object(
        'total_invitations', (SELECT COUNT(*) FROM invitations WHERE user_id = p_user_id),
        'published_invitations', (SELECT COUNT(*) FROM invitations WHERE user_id = p_user_id AND status = 'published'),
        'total_guests', (SELECT COUNT(*) FROM guests g JOIN invitations i ON g.invitation_id = i.id WHERE i.user_id = p_user_id),
        'total_rsvp', (SELECT COUNT(*) FROM guests g JOIN invitations i ON g.invitation_id = i.id WHERE i.user_id = p_user_id AND g.rsvp_status IS NOT NULL),
        'total_views', (SELECT COALESCE(SUM(view_count), 0) FROM invitations WHERE user_id = p_user_id),
        'total_envelope_received', (SELECT COALESCE(SUM(ep.amount), 0) FROM envelope_payments ep JOIN invitations i ON ep.invitation_id = i.id WHERE i.user_id = p_user_id AND ep.status = 'success'),
        'recent_messages', (
            SELECT json_agg(row_to_json(m))
            FROM (
                SELECT gm.*, i.slug as invitation_slug
                FROM guest_messages gm
                JOIN invitations i ON gm.invitation_id = i.id
                WHERE i.user_id = p_user_id
                ORDER BY gm.created_at DESC
                LIMIT 5
            ) m
        )
    ) INTO result;

    RETURN result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
