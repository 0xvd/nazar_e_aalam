<?php

namespace App\Http\Controllers\Quran\Blog;

use App\Concerns\FileHandler;
use App\Concerns\HandlesChunkedUploads;
use App\Http\Controllers\Controller;
use App\Models\BlogPost;
use Illuminate\Http\Request;
use Illuminate\Http\UploadedFile;
use Illuminate\Support\Facades\Log;

class BlogController extends Controller
{
    use FileHandler, HandlesChunkedUploads;

    private const MAX_CHUNK_SIZE = 2 * 1024 * 1024; // 2 MB per chunk
    private const MAX_THUMBNAIL_SIZE = 3072 * 1024; // matches the 3MB cap below
    private const ALLOWED_THUMBNAIL_EXTENSIONS = ['jpg', 'jpeg', 'png', 'gif', 'webp'];

    public function index()
    {
        return BlogPost::orderByDesc('published_at')->orderByDesc('created_at')->paginate(20);
    }

    public function store(Request $request)
    {
        $data = $this->validated($request);
        $data = $this->handleThumbnail($data);
        if ($data['status'] === 'published' && empty($data['published_at'])) {
            $data['published_at'] = now();
        }
        $post = BlogPost::create($data);
        return response()->json(['success' => true, 'message' => 'Post created successfully.', 'data' => $post], 201);
    }

    public function show(BlogPost $blog)
    {
        return response()->json($blog);
    }

    public function update(Request $request, BlogPost $blog)
    {
        $data = $this->validated($request, $blog);
        $data = $this->handleThumbnail($data, $blog);
        if ($data['status'] === 'published' && empty($blog->published_at)) {
            $data['published_at'] = now();
        }
        $blog->update($data);
        return response()->json(['success' => true, 'message' => 'Post updated successfully.', 'data' => $blog->fresh()]);
    }

    public function uploadContentImage(Request $request)
    {
        $request->validate([
            'image' => ['required', 'image', 'max:5120'],
        ]);
        $url = $this->uploadImage($request->file('image'), 'blog-content', 1000);
        return response()->json(['success' => true, 'url' => $url]);
    }

    public function destroy(BlogPost $blog)
    {
        $this->deleteImage($blog->thumbnail);
        $blog->delete();
        return response()->json(['success' => true, 'message' => 'Post deleted successfully.']);
    }

    // The thumbnail is always pre-uploaded chunk-by-chunk via uploadThumbnailChunk/
    // completeThumbnailUpload before submit, so by the time store/update runs it is
    // already a stored path string, not a file. This keeps the create/update request
    // body small (title + content + a short path) instead of carrying the raw image,
    // which is what was tripping the server's body-size limit on large images.
    public function uploadThumbnailChunk(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId'     => ['required', 'string'],
            'chunkNumber'  => ['required', 'integer', 'min:1'],
            'totalChunks'  => ['required', 'integer', 'min:1'],
            'fileName'     => ['required', 'string'],
            'file'         => ['required', 'file', 'max:' . (self::MAX_CHUNK_SIZE / 1024)],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);

        if ($validatedData['chunkNumber'] > $validatedData['totalChunks']) {
            return response()->json(['status' => false, 'message' => 'Invalid chunk number'], 422);
        }

        $manifest = $this->readManifest($uploadId);

        if ($manifest && (int)$manifest['totalChunks'] !== (int)$validatedData['totalChunks']) {
            return response()->json([
                'status' => false,
                'message' => 'Upload session mismatch, please cancel and restart this upload',
            ], 409);
        }

        if (!$manifest) {
            $manifest = [
                'fileName' => $validatedData['fileName'],
                'totalChunks' => (int)$validatedData['totalChunks'],
                'receivedChunks' => [],
            ];
        }

        try {
            $tempDir = $this->chunkTempDir($uploadId);
            $request->file('file')->move($tempDir, "chunk_{$validatedData['chunkNumber']}");

            $manifest['receivedChunks'] = array_values(array_unique(array_merge(
                $manifest['receivedChunks'],
                [(int)$validatedData['chunkNumber']]
            )));
            $this->writeManifest($uploadId, $manifest);

            return response()->json([
                'status' => 'chunk_uploaded',
                'receivedChunks' => $manifest['receivedChunks'],
                'totalChunks' => $manifest['totalChunks'],
            ]);
        } catch (\Exception $e) {
            Log::error("Error while uploading thumbnail chunk {$validatedData['chunkNumber']} for upload {$uploadId}: " . $e->getMessage());
            return response()->json(['status' => false, 'message' => 'Error while uploading chunk'], 500);
        }
    }

    public function thumbnailUploadStatus(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $manifest = $this->readManifest($uploadId);

        if (!$manifest) {
            return response()->json(['exists' => false, 'receivedChunks' => []]);
        }

        return response()->json([
            'exists' => true,
            'receivedChunks' => $manifest['receivedChunks'],
            'totalChunks' => $manifest['totalChunks'],
            'fileName' => $manifest['fileName'],
        ]);
    }

    public function completeThumbnailUpload(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId'    => ['required', 'string'],
            'totalChunks' => ['required', 'integer', 'min:1'],
            'fileName'    => ['required', 'string'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $tempDir = $this->chunkTempDir($uploadId);
        $manifest = $this->readManifest($uploadId);

        if (!$manifest) {
            return response()->json(['status' => false, 'message' => 'Upload session not found'], 404);
        }

        $totalChunks = (int)$validatedData['totalChunks'];
        $missingChunks = [];

        for ($i = 1; $i <= $totalChunks; $i++) {
            $chunkPath = "{$tempDir}/chunk_{$i}";
            if (!in_array($i, $manifest['receivedChunks']) || !file_exists($chunkPath) || filesize($chunkPath) === 0) {
                $missingChunks[] = $i;
            }
        }

        if (!empty($missingChunks)) {
            return response()->json([
                'status' => false,
                'message' => 'Upload incomplete, some chunks are missing',
                'missingChunks' => $missingChunks,
            ], 409);
        }

        $extension = strtolower(pathinfo($validatedData['fileName'], PATHINFO_EXTENSION));

        if (!in_array($extension, self::ALLOWED_THUMBNAIL_EXTENSIONS)) {
            $this->removeDirectory($tempDir);
            return response()->json(['status' => false, 'message' => 'Unsupported image type'], 422);
        }

        $assembledPath = "{$tempDir}/assembled.{$extension}";

        try {
            $mergedStream = fopen($assembledPath, 'w+');
            for ($i = 1; $i <= $totalChunks; $i++) {
                $chunkStream = fopen("{$tempDir}/chunk_{$i}", 'r');
                stream_copy_to_stream($chunkStream, $mergedStream);
                fclose($chunkStream);
            }
            fclose($mergedStream);

            if (filesize($assembledPath) > self::MAX_THUMBNAIL_SIZE) {
                $this->removeDirectory($tempDir);
                return response()->json(['status' => false, 'message' => 'Image must not be larger than 3MB'], 422);
            }

            $mimeType = mime_content_type($assembledPath);
            if (!str_starts_with($mimeType, 'image/') || !getimagesize($assembledPath)) {
                $this->removeDirectory($tempDir);
                return response()->json(['status' => false, 'message' => 'Uploaded file is not a valid image'], 422);
            }

            $uploadedFile = new UploadedFile($assembledPath, $validatedData['fileName'], $mimeType, null, true);
            $path = $this->uploadImage($uploadedFile, 'blog', 600);

            $this->removeDirectory($tempDir);

            return response()->json(['status' => 'completed', 'path' => $path]);
        } catch (\Exception $exception) {
            Log::error("Error merging thumbnail chunks for upload {$uploadId}: " . $exception->getMessage());
            $this->removeDirectory($tempDir);
            return response()->json(['status' => false, 'message' => 'Error merging chunks'], 500);
        }
    }

    public function cancelThumbnailUpload(Request $request)
    {
        $validatedData = $request->validate([
            'uploadId' => ['required', 'string'],
        ]);

        $uploadId = $this->validateUploadId($validatedData['uploadId']);
        $this->removeDirectory($this->chunkTempDir($uploadId));

        return response()->json(['status' => true]);
    }

    private function validated(Request $request, ?BlogPost $post = null): array
    {
        $slugRule = $post ? "unique:blog_posts,slug,{$post->id}" : 'unique:blog_posts,slug';
        return $request->validate([
            'title'            => ['required', 'string', 'max:200'],
            'slug'             => ['nullable', 'string', 'max:220', $slugRule],
            'category'         => ['nullable', 'string', 'max:80'],
            'excerpt'          => ['nullable', 'string', 'max:500'],
            'content'          => ['required', 'string'],
            'meta_title'       => ['nullable', 'string', 'max:70'],
            'meta_description' => ['nullable', 'string', 'max:200'],
            'status'           => ['required', 'in:draft,published'],
            'thumbnail'        => ['nullable', 'string', 'max:255'],
        ]);
    }

    private function handleThumbnail(array $data, ?BlogPost $existing = null): array
    {
        if (empty($data['thumbnail'])) {
            unset($data['thumbnail']);
            return $data;
        }
        if ($existing && $existing->thumbnail && $existing->thumbnail !== $data['thumbnail']) {
            $this->deleteImage($existing->thumbnail);
        }
        return $data;
    }
}
