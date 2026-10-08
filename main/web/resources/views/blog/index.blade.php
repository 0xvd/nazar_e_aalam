<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Blog – {{ $s['app_name'] ?? 'Zabi' }}</title>
    <meta name="description" content="Islamic articles, guides, and updates from {{ $s['app_name'] ?? 'Zabi' }}">
    <link rel="icon" href="{{ asset('favicon.ico') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f8faf9; color: #1a1f2e; }

        /* Topbar */
        .topbar {
            background: linear-gradient(135deg, #0a2e1e 0%, #1a5c38 100%);
            padding: 14px 32px;
            display: flex; align-items: center; justify-content: space-between;
            position: sticky; top: 0; z-index: 50;
            box-shadow: 0 2px 12px rgba(0,0,0,.25);
        }
        .topbar-brand { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .topbar-logo { height: 36px; width: auto; max-width: 140px; object-fit: contain; }
        .topbar-name { color: #fff; font-weight: 700; font-size: 1.15rem; }
        .topbar-link { color: rgba(255,255,255,.75); font-size: .82rem; font-weight: 500; text-decoration: none; padding: 7px 14px; border: 1px solid rgba(255,255,255,.2); border-radius: 8px; transition: background .15s; }
        .topbar-link:hover { background: rgba(255,255,255,.1); color: #fff; }

        /* Hero */
        .hero {
            background: linear-gradient(135deg, #0a2e1e 0%, #1a5c38 60%, #0d3d26 100%);
            padding: 64px 32px 56px; text-align: center;
        }
        .hero-badge { display: inline-flex; align-items: center; gap: 6px; background: rgba(212,168,67,.15); border: 1px solid rgba(212,168,67,.3); color: #d4a843; font-size: .75rem; font-weight: 600; padding: 5px 14px; border-radius: 20px; margin-bottom: 18px; }
        .hero h1 { color: #fff; font-size: 2.4rem; font-weight: 800; margin-bottom: 12px; }
        .hero p { color: rgba(255,255,255,.65); font-size: 1rem; max-width: 520px; margin: 0 auto; }

        /* Grid */
        .container { max-width: 1120px; margin: 0 auto; padding: 0 24px; }
        .grid-section { padding: 56px 0 80px; }
        .posts-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 24px; }

        .post-card {
            background: #fff; border-radius: 16px; border: 1px solid #e8ecf0;
            overflow: hidden; transition: transform .2s, box-shadow .2s;
            text-decoration: none; color: inherit; display: flex; flex-direction: column;
        }
        .post-card:hover { transform: translateY(-4px); box-shadow: 0 12px 36px rgba(0,0,0,.1); }
        .post-card-img { width: 100%; height: 180px; object-fit: cover; background: #e8ecf0; }
        .post-card-img-placeholder { height: 180px; background: linear-gradient(135deg, #0a2e1e22, #1a5c3822); display: flex; align-items: center; justify-content: center; font-size: 2.5rem; }
        .post-card-body { padding: 20px; flex: 1; display: flex; flex-direction: column; }
        .post-category { font-size: .7rem; font-weight: 700; color: #1a5c38; text-transform: uppercase; letter-spacing: .08em; margin-bottom: 8px; }
        .post-card-title { font-size: 1rem; font-weight: 700; color: #0a2e1e; margin-bottom: 8px; line-height: 1.4; }
        .post-card-excerpt { font-size: .85rem; color: #6b7280; line-height: 1.6; flex: 1; margin-bottom: 16px; }
        .post-card-meta { font-size: .75rem; color: #9aa3b5; display: flex; align-items: center; gap: 6px; }
        .post-card-meta span { display: flex; align-items: center; gap: 4px; }

        /* Pagination */
        .pagination { display: flex; justify-content: center; gap: 8px; margin-top: 48px; }
        .page-link { padding: 8px 16px; border: 1.5px solid #e4e8f0; border-radius: 8px; font-size: .85rem; color: #1a1f2e; text-decoration: none; transition: all .15s; }
        .page-link:hover, .page-link.active { background: #1a5c38; color: #fff; border-color: #1a5c38; }
        .page-link.disabled { opacity: .4; pointer-events: none; }

        /* Empty */
        .empty { text-align: center; padding: 80px 24px; }
        .empty-icon { font-size: 3rem; margin-bottom: 16px; }
        .empty h3 { font-size: 1.2rem; font-weight: 700; color: #0a2e1e; margin-bottom: 8px; }
        .empty p { color: #6b7280; font-size: .9rem; }

        /* Footer */
        .page-footer { background: #0a2e1e; padding: 24px; text-align: center; color: rgba(255,255,255,.45); font-size: .8rem; }
        .page-footer a { color: rgba(255,255,255,.6); text-decoration: none; margin: 0 8px; }
        .page-footer a:hover { color: #d4a843; }

        @media (max-width: 900px) { .posts-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 600px) { .posts-grid { grid-template-columns: 1fr; } .hero h1 { font-size: 1.7rem; } }
    </style>
</head>
<body>

<header class="topbar">
    <a href="{{ url('/') }}" class="topbar-brand">
        @if(!empty($s['web_logo']))
            <img src="{{ asset($s['web_logo']) }}" alt="{{ $s['app_name'] ?? 'Zabi' }}" class="topbar-logo">
        @else
            <span class="topbar-name">{{ $s['app_name'] ?? 'Zabi' }}</span>
        @endif
    </a>
    <a href="{{ url('/') }}" class="topbar-link">← Back to Home</a>
</header>

<div class="hero">
    <div class="hero-badge">✍️ Blog</div>
    <h1>Islamic Articles &amp; Guides</h1>
    <p>Insights, tips, and Islamic knowledge from the {{ $s['app_name'] ?? 'Zabi' }} team</p>
</div>

<div class="container grid-section">
    @if($posts->isEmpty())
        <div class="empty">
            <div class="empty-icon">📝</div>
            <h3>No posts yet</h3>
            <p>Check back soon for Islamic articles and updates.</p>
        </div>
    @else
        <div class="posts-grid">
            @foreach($posts as $post)
            <a href="{{ route('blog.show', $post->slug) }}" class="post-card">
                @if($post->thumbnail)
                    <img src="{{ asset($post->thumbnail) }}" alt="{{ $post->title }}" class="post-card-img">
                @else
                    <div class="post-card-img-placeholder">🕌</div>
                @endif
                <div class="post-card-body">
                    <p class="post-category">{{ $post->category }}</p>
                    <h2 class="post-card-title">{{ $post->title }}</h2>
                    @if($post->excerpt)
                        <p class="post-card-excerpt">{{ Str::limit($post->excerpt, 120) }}</p>
                    @endif
                    <div class="post-card-meta">
                        <span>📅 {{ $post->published_at?->format('d M Y') }}</span>
                    </div>
                </div>
            </a>
            @endforeach
        </div>

        {{-- Pagination --}}
        @if($posts->lastPage() > 1)
        <div class="pagination">
            @if($posts->onFirstPage())
                <span class="page-link disabled">← Prev</span>
            @else
                <a href="{{ $posts->previousPageUrl() }}" class="page-link">← Prev</a>
            @endif
            @for($p = 1; $p <= $posts->lastPage(); $p++)
                <a href="{{ $posts->url($p) }}" class="page-link {{ $p === $posts->currentPage() ? 'active' : '' }}">{{ $p }}</a>
            @endfor
            @if($posts->hasMorePages())
                <a href="{{ $posts->nextPageUrl() }}" class="page-link">Next →</a>
            @else
                <span class="page-link disabled">Next →</span>
            @endif
        </div>
        @endif
    @endif
</div>

<footer class="page-footer">
    <p>© {{ date('Y') }} {{ $s['app_name'] ?? 'Zabi' }}. All rights reserved.</p>
    <p style="margin-top:8px;">
        <a href="{{ url('/') }}">Home</a>
        <a href="{{ url('privacy-policy') }}">Privacy Policy</a>
        <a href="{{ url('terms-and-conditions') }}">Terms</a>
        <a href="{{ url('support') }}">Support</a>
    </p>
</footer>

</body>
</html>
