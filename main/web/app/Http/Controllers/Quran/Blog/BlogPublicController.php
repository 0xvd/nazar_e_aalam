<?php

namespace App\Http\Controllers\Quran\Blog;

use App\Http\Controllers\Controller;
use App\Models\BlogPost;
use App\Services\Setting\SettingService;

class BlogPublicController extends Controller
{
    public function index()
    {
        $posts = BlogPost::published()
            ->orderByDesc('published_at')
            ->paginate(9);

        $s = $this->seoSettings();
        return view('blog.index', compact('posts', 's'));
    }

    public function show(string $slug)
    {
        $post = BlogPost::published()->where('slug', $slug)->firstOrFail();
        $related = BlogPost::published()
            ->where('id', '!=', $post->id)
            ->where('category', $post->category)
            ->latest('published_at')
            ->limit(3)
            ->get();

        $s = $this->seoSettings();
        return view('blog.show', compact('post', 'related', 's'));
    }

    private function seoSettings(): array
    {
        try {
            $landing = resolve(SettingService::class)->getFormattedSettings('landing');
            $app     = resolve(SettingService::class)->getFormattedSettings('app');
        } catch (\Throwable) {
            $landing = [];
            $app     = [];
        }
        return array_merge([
            'app_name' => 'Zabi',
            'web_logo' => $app['web_logo'] ?? null,
        ], (array) $landing, (array) $app);
    }
}
