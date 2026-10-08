<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>{{ $post->meta_title ?: $post->title }} – {{ $s['app_name'] ?? 'Zabi' }}</title>
    <meta name="description" content="{{ $post->meta_description ?: Str::limit($post->excerpt ?? strip_tags($post->content), 160) }}">
    <meta property="og:type" content="article">
    <meta property="og:title" content="{{ $post->meta_title ?: $post->title }}">
    <meta property="og:description" content="{{ $post->meta_description ?: Str::limit($post->excerpt ?? strip_tags($post->content), 160) }}">
    @if($post->thumbnail)<meta property="og:image" content="{{ asset($post->thumbnail) }}">@endif
    <meta property="og:url" content="{{ url()->current() }}">
    <link rel="canonical" href="{{ url()->current() }}">
    <link rel="icon" href="{{ asset('favicon.ico') }}">
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700;800&family=Amiri:wght@400;700&display=swap" rel="stylesheet">
    <style>
        *, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
        body { font-family: 'Inter', sans-serif; background: #f8faf9; color: #1a1f2e; }

        .topbar { background: linear-gradient(135deg, #0a2e1e 0%, #1a5c38 100%); padding: 14px 32px; display: flex; align-items: center; justify-content: space-between; position: sticky; top: 0; z-index: 50; box-shadow: 0 2px 12px rgba(0,0,0,.25); }
        .topbar-brand { display: flex; align-items: center; gap: 10px; text-decoration: none; }
        .topbar-logo { height: 36px; width: auto; max-width: 140px; object-fit: contain; }
        .topbar-name { color: #fff; font-weight: 700; font-size: 1.15rem; }
        .topbar-links { display: flex; gap: 10px; }
        .topbar-link { color: rgba(255,255,255,.75); font-size: .82rem; font-weight: 500; text-decoration: none; padding: 7px 14px; border: 1px solid rgba(255,255,255,.2); border-radius: 8px; transition: background .15s; }
        .topbar-link:hover { background: rgba(255,255,255,.1); color: #fff; }

        /* Hero image */
        .post-hero { display: block; width: 100%; max-width: 900px; height: auto; margin: 24px auto; border-radius: 16px; }
        .post-hero-placeholder { height: 200px; background: linear-gradient(135deg, #0a2e1e, #1a5c38); display: flex; align-items: center; justify-content: center; font-size: 3rem; }

        /* Layout */
        .article-wrap { max-width: 780px; margin: 0 auto; padding: 48px 24px 80px; }

        /* Meta */
        .post-meta { display: flex; align-items: center; gap: 12px; margin-bottom: 20px; flex-wrap: wrap; }
        .meta-category { background: #e8f5ee; color: #1a5c38; font-size: .72rem; font-weight: 700; padding: 4px 12px; border-radius: 20px; text-transform: uppercase; letter-spacing: .06em; }
        .meta-date { font-size: .82rem; color: #9aa3b5; }

        /* Title */
        .post-title { font-size: 2rem; font-weight: 800; color: #0a2e1e; line-height: 1.25; margin-bottom: 16px; }
        .post-excerpt { font-size: 1.05rem; color: #6b7280; line-height: 1.7; margin-bottom: 32px; border-left: 3px solid #1a5c38; padding-left: 16px; }

        /* Content */
        .post-content { font-size: .97rem; line-height: 1.85; color: #374151; }
        .post-content h1, .post-content h2, .post-content h3 { color: #0a2e1e; margin: 1.8em 0 .6em; line-height: 1.3; }
        .post-content h2 { font-size: 1.35rem; font-weight: 700; }
        .post-content h3 { font-size: 1.1rem; font-weight: 600; }
        .post-content p { margin-bottom: 1em; }
        .post-content ul, .post-content ol { padding-left: 1.5em; margin-bottom: 1em; }
        .post-content li { margin-bottom: .4em; }
        .post-content a { color: #1a5c38; text-decoration: underline; }
        .post-content blockquote { border-left: 4px solid #d4a843; padding: 12px 20px; background: #fffbeb; border-radius: 0 8px 8px 0; margin: 1.2em 0; font-style: italic; color: #6b7280; }
        .post-content img { max-width: 100%; border-radius: 12px; margin: 1em 0; }
        .post-content strong { color: #1a1f2e; }
        .post-content pre { background: #1a1f2e; color: #e2e8f0; padding: 16px; border-radius: 10px; overflow-x: auto; font-size: .85rem; margin: 1em 0; }
        .post-content code { background: #f0f4f8; padding: 2px 6px; border-radius: 4px; font-size: .88em; }
        .post-content pre code { background: none; padding: 0; }

        /* Divider */
        .post-divider { border: none; border-top: 1px solid #e8ecf0; margin: 48px 0; }

        /* Related */
        .related-title { font-size: 1.1rem; font-weight: 700; color: #0a2e1e; margin-bottom: 20px; }
        .related-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
        .related-card { background: #fff; border-radius: 12px; border: 1px solid #e8ecf0; overflow: hidden; text-decoration: none; color: inherit; transition: transform .18s, box-shadow .18s; }
        .related-card:hover { transform: translateY(-3px); box-shadow: 0 8px 24px rgba(0,0,0,.08); }
        .related-img { width: 100%; height: 110px; object-fit: cover; background: #e8ecf0; }
        .related-placeholder { height: 110px; background: linear-gradient(135deg, #0a2e1e22, #1a5c3822); display: flex; align-items: center; justify-content: center; font-size: 1.8rem; }
        .related-body { padding: 12px 14px; }
        .related-cat { font-size: .68rem; font-weight: 700; color: #1a5c38; text-transform: uppercase; letter-spacing: .06em; margin-bottom: 4px; }
        .related-card-title { font-size: .85rem; font-weight: 600; color: #0a2e1e; line-height: 1.4; }

        /* Back link */
        .back-link { display: inline-flex; align-items: center; gap: 6px; color: #1a5c38; font-size: .85rem; font-weight: 500; text-decoration: none; margin-bottom: 24px; }
        .back-link:hover { color: #0a2e1e; }

        .page-footer { background: #0a2e1e; padding: 24px; text-align: center; color: rgba(255,255,255,.45); font-size: .8rem; }
        .page-footer a { color: rgba(255,255,255,.6); text-decoration: none; margin: 0 8px; }
        .page-footer a:hover { color: #d4a843; }

        @media (max-width: 700px) { .related-grid { grid-template-columns: 1fr 1fr; } .post-title { font-size: 1.5rem; } }
        @media (max-width: 480px) { .related-grid { grid-template-columns: 1fr; } }
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
    <div class="topbar-links">
        <a href="{{ route('blog.index') }}" class="topbar-link">Blog</a>
        <a href="{{ url('/') }}" class="topbar-link">Home</a>
    </div>
</header>

@if($post->thumbnail)
    <img src="{{ asset($post->thumbnail) }}" alt="{{ $post->title }}" class="post-hero">
@else
    <div class="post-hero-placeholder">🕌</div>
@endif

<div class="article-wrap">
    <a href="{{ route('blog.index') }}" class="back-link">← All Articles</a>

    <div class="post-meta">
        <span class="meta-category">{{ $post->category }}</span>
        @if($post->published_at)
            <span class="meta-date">📅 {{ $post->published_at->format('d F Y') }}</span>
        @endif
    </div>

    <h1 class="post-title">{{ $post->title }}</h1>

    @if($post->excerpt)
        <p class="post-excerpt">{{ $post->excerpt }}</p>
    @endif

    <div class="post-content">
        {!! $post->content !!}
    </div>

    @if($related->count())
        <hr class="post-divider">
        <p class="related-title">More Articles</p>
        <div class="related-grid">
            @foreach($related as $rel)
            <a href="{{ route('blog.show', $rel->slug) }}" class="related-card">
                @if($rel->thumbnail)
                    <img src="{{ asset($rel->thumbnail) }}" alt="{{ $rel->title }}" class="related-img">
                @else
                    <div class="related-placeholder">📖</div>
                @endif
                <div class="related-body">
                    <p class="related-cat">{{ $rel->category }}</p>
                    <p class="related-card-title">{{ $rel->title }}</p>
                </div>
            </a>
            @endforeach
        </div>
    @endif
</div>

<footer class="page-footer">
    <p>© {{ date('Y') }} {{ $s['app_name'] ?? 'Zabi' }}. All rights reserved.</p>
    <p style="margin-top:8px;">
        <a href="{{ url('/') }}">Home</a>
        <a href="{{ route('blog.index') }}">Blog</a>
        <a href="{{ url('privacy-policy') }}">Privacy Policy</a>
        <a href="{{ url('terms-and-conditions') }}">Terms</a>
    </p>
</footer>

</body>
</html>
