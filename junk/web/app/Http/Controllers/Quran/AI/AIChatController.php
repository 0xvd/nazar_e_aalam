<?php

namespace App\Http\Controllers\Quran\AI;

use App\Http\Controllers\Controller;
use App\Services\Setting\SettingService;
use Illuminate\Contracts\Encryption\DecryptException;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class AIChatController extends Controller
{

    public function __construct(SettingService $service)
    {
        $this->service = $service;
    }


    private function groqChat(array $messages, int $maxTokens = 600): string
    {

        $settings = $this->service->getFormattedSettings();

        $response = Http::timeout(30)->withHeaders([
            'Authorization' => 'Bearer ' . $this->safeDecrypt($settings['islamic_name_api_key']),
        ])->post('https://api.groq.com/openai/v1/chat/completions', [
            'model'       => 'llama-3.3-70b-versatile',
            'messages'    => $messages,
            'max_tokens'  => $maxTokens,
            'temperature' => 0.7,
        ]);

        if (!$response->successful()) {
            throw new \Exception('Groq API error: ' . $response->status());
        }

        return $response->json('choices.0.message.content', '');
    }



    public function chat(Request $request)
    {
        $request->validate(['message' => 'required|string|max:500']);

        try {
            $reply = $this->groqChat([
                [
                    'role'    => 'system',
                    'content' => 'You are Zabi AI, a knowledgeable Islamic scholar assistant. Answer questions about Islam, Quran, Hadith, prayer, fiqh, Islamic history, halal/haram, duas, and Islamic lifestyle. Be respectful, accurate, and cite Quranic verses or hadith references when relevant. Include Arabic text for prayers and duas with English translation. Keep answers helpful, clear, and concise. If asked about unrelated topics, politely redirect to Islamic subjects.',
                ],
                ['role' => 'user', 'content' => $request->message],
            ], 600);

            return response()->json(['success' => true, 'reply' => $reply]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => 'AI service temporarily unavailable. Please try again.'], 503);
        }
    }

    public function generateNames(Request $request)
    {
        $request->validate([
            'gender' => 'required|in:boy,girl',
            'theme'  => 'nullable|string|max:100',
        ]);

        $gender      = $request->gender;
        $theme       = trim($request->theme ?? '');
        $themeClause = $theme ? " with names that relate to the theme '{$theme}'" : '';

        $prompt = "Generate 6 beautiful Islamic names for a {$gender}{$themeClause}. Return ONLY a valid JSON array with no markdown, no explanation. Each object must have exactly: \"arabic\" (Arabic script), \"name\" (English transliteration), \"meaning\" (clear English meaning), \"origin\" (e.g. Arabic, Persian, Urdu). Example: [{\"arabic\":\"عبدالله\",\"name\":\"Abdullah\",\"meaning\":\"Servant of Allah\",\"origin\":\"Arabic\"}]";

        try {
            $content = $this->groqChat([
                ['role' => 'system', 'content' => 'You are an Islamic names expert. Always respond with a valid JSON array only — no markdown fences, no explanation, no other text.'],
                ['role' => 'user', 'content' => $prompt],
            ], 1000);

            preg_match('/\[[\s\S]*\]/u', $content, $m);
            $names = json_decode($m[0] ?? '[]', true) ?? [];

            return response()->json(['success' => true, 'names' => $names]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => 'AI service temporarily unavailable. Please try again.'], 503);
        }
    }

    protected function safeDecrypt($value)
    {
        try {
            return decrypt($value);
        } catch (DecryptException $e) {
            return $value;
        }
    }
}
