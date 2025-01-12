select* from website_pageviews;
select * from website_sessions;

WITH pageview_session AS (
    SELECT MIN(wp.website_pageview_id), ws.website_session_id, wp.pageview_url
    FROM website_pageviews wp
    JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
    WHERE ws.utm_campaign = 'nonbrand'
          AND ws.utm_source = 'gsearch'
          AND ws.created_at < '2012-07-29'
          AND website_pageview_id > 23504 
    GROUP BY ws.website_session_id, wp.pageview_url  
),
first_page_view AS (
    SELECT website_session_id, pageview_url
    FROM pageview_session 
    WHERE pageview_url IN ('/lander-1', '/home')
),
bounch_view AS (
    SELECT f.website_session_id, COUNT(w.website_pageview_id), f.pageview_url
    FROM first_page_view f
    LEFT JOIN website_pageviews w ON f.website_session_id = w.website_session_id
    GROUP BY f.pageview_url, f.website_session_id
    HAVING COUNT(w.website_pageview_id) = 1
)
SELECT COUNT(f.website_session_id) sessions,
       COUNT(b.website_session_id) bounch_session,
       COUNT(b.website_session_id)::FLOAT / COUNT(f.website_session_id) * 100 AS bounch_rate,
       f.pageview_url AS landing_page
FROM first_page_view f
LEFT JOIN bounch_view b ON f.website_session_id = b.website_session_id
GROUP BY f.pageview_url;
