<?php

namespace App\Support;

/**
 * Dependency-free MP3 duration estimator.
 *
 * Reads the first valid MPEG audio frame header and, where present, the
 * Xing/Info or VBRI header to accurately time variable-bitrate files.
 * Falls back to a constant-bitrate estimate from the file size. Returns
 * whole seconds, or 0 when the file can't be parsed — so a bad file never
 * breaks an import.
 */
class Mp3Duration
{
    // Bitrate (kbps) tables keyed by version group + layer, indexed by the 4-bit field.
    private const BITRATES = [
        'V1L1' => [0, 32, 64, 96, 128, 160, 192, 224, 256, 288, 320, 352, 384, 416, 448, 0],
        'V1L2' => [0, 32, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 384, 0],
        'V1L3' => [0, 32, 40, 48, 56, 64, 80, 96, 112, 128, 160, 192, 224, 256, 320, 0],
        'V2L1' => [0, 32, 48, 56, 64, 80, 96, 112, 128, 144, 160, 176, 192, 224, 256, 0],
        'V2L2' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
        'V2L3' => [0, 8, 16, 24, 32, 40, 48, 56, 64, 80, 96, 112, 128, 144, 160, 0],
    ];

    // Sample rate (Hz) keyed by MPEG version, indexed by the 2-bit field.
    private const SAMPLE_RATES = [
        'V1' => [44100, 48000, 32000, 0],   // MPEG1
        'V2' => [22050, 24000, 16000, 0],   // MPEG2
        'V25' => [11025, 12000, 8000, 0],   // MPEG2.5
    ];

    public static function fromFile(string $path): int
    {
        try {
            return (int) round(self::parse($path));
        } catch (\Throwable $e) {
            return 0;
        }
    }

    private static function parse(string $path): float
    {
        $handle = @fopen($path, 'rb');
        if ($handle === false) {
            return 0.0;
        }

        try {
            $fileSize = filesize($path) ?: 0;
            $offset = self::skipId3v2($handle);

            // Scan a bounded window for the first valid frame sync.
            $scanLimit = $offset + 200000;
            fseek($handle, $offset);

            while ($offset < $scanLimit) {
                fseek($handle, $offset);
                $header = fread($handle, 4);

                if (strlen($header) < 4) {
                    return 0.0;
                }

                $bytes = array_values(unpack('C4', $header));

                // Frame sync: 11 bits set (0xFF followed by 0xE0..).
                if ($bytes[0] !== 0xFF || ($bytes[1] & 0xE0) !== 0xE0) {
                    $offset++;
                    continue;
                }

                $frame = self::decodeHeader($bytes);
                if ($frame === null) {
                    $offset++;
                    continue;
                }

                // Try VBR headers first for accuracy.
                $frameCount = self::readVbrFrameCount($handle, $offset, $frame);
                if ($frameCount !== null && $frame['sampleRate'] > 0) {
                    return ($frameCount * $frame['samplesPerFrame']) / $frame['sampleRate'];
                }

                // Constant-bitrate estimate from remaining audio bytes.
                if ($frame['bitrate'] > 0) {
                    $audioBytes = $fileSize - $offset;
                    return ($audioBytes * 8) / ($frame['bitrate'] * 1000);
                }

                return 0.0;
            }

            return 0.0;
        } finally {
            fclose($handle);
        }
    }

    /**
     * Skip an ID3v2 tag if present and return the byte offset where audio begins.
     */
    private static function skipId3v2($handle): int
    {
        fseek($handle, 0);
        $tag = fread($handle, 10);

        if (strlen($tag) === 10 && substr($tag, 0, 3) === 'ID3') {
            $b = array_values(unpack('C10', $tag));
            // Synchsafe 28-bit size in the last 4 bytes.
            $size = ($b[6] << 21) | ($b[7] << 14) | ($b[8] << 7) | $b[9];
            return 10 + $size;
        }

        return 0;
    }

    private static function decodeHeader(array $bytes): ?array
    {
        $versionBits = ($bytes[1] >> 3) & 0x03;
        $layerBits = ($bytes[1] >> 1) & 0x03;
        $bitrateIndex = ($bytes[2] >> 4) & 0x0F;
        $sampleRateIndex = ($bytes[2] >> 2) & 0x03;

        // Reserved values are invalid.
        if ($versionBits === 0x01 || $layerBits === 0x00 || $bitrateIndex === 0x0F || $sampleRateIndex === 0x03) {
            return null;
        }

        $version = match ($versionBits) {
            0x00 => 'V25',
            0x02 => 'V2',
            0x03 => 'V1',
            default => null,
        };
        $layer = match ($layerBits) {
            0x01 => 3,
            0x02 => 2,
            0x03 => 1,
            default => null,
        };
        if ($version === null || $layer === null) {
            return null;
        }

        $versionGroup = $version === 'V1' ? 'V1' : 'V2';
        $bitrateKey = "{$versionGroup}L{$layer}";
        $bitrate = self::BITRATES[$bitrateKey][$bitrateIndex] ?? 0;
        $sampleRate = self::SAMPLE_RATES[$version][$sampleRateIndex] ?? 0;

        // Samples per frame depends on layer and MPEG version.
        $samplesPerFrame = match ($layer) {
            1 => 384,
            2 => 1152,
            3 => $version === 'V1' ? 1152 : 576,
            default => 0,
        };

        $channelBits = ($bytes[3] >> 6) & 0x03;
        $isMono = $channelBits === 0x03;

        return [
            'version' => $version,
            'layer' => $layer,
            'bitrate' => $bitrate,
            'sampleRate' => $sampleRate,
            'samplesPerFrame' => $samplesPerFrame,
            'isMono' => $isMono,
        ];
    }

    /**
     * Read a Xing/Info or VBRI frame count if the header carries one.
     */
    private static function readVbrFrameCount($handle, int $frameOffset, array $frame): ?int
    {
        // Xing/Info sits after the frame header + side information.
        if ($frame['version'] === 'V1') {
            $sideInfo = $frame['isMono'] ? 17 : 32;
        } else {
            $sideInfo = $frame['isMono'] ? 9 : 17;
        }

        $xingOffset = $frameOffset + 4 + $sideInfo;
        fseek($handle, $xingOffset);
        $marker = fread($handle, 4);

        if ($marker === 'Xing' || $marker === 'Info') {
            $flags = fread($handle, 4);
            if (strlen($flags) === 4) {
                $flagBits = unpack('N', $flags)[1];
                if ($flagBits & 0x01) { // frames field present
                    $framesRaw = fread($handle, 4);
                    if (strlen($framesRaw) === 4) {
                        return unpack('N', $framesRaw)[1];
                    }
                }
            }
        }

        // VBRI is fixed at 32 bytes past the frame header.
        $vbriOffset = $frameOffset + 4 + 32;
        fseek($handle, $vbriOffset);
        $vbriMarker = fread($handle, 4);
        if ($vbriMarker === 'VBRI') {
            // frames count is a 32-bit BE int at offset +14 from the marker.
            fseek($handle, $vbriOffset + 14);
            $framesRaw = fread($handle, 4);
            if (strlen($framesRaw) === 4) {
                return unpack('N', $framesRaw)[1];
            }
        }

        return null;
    }
}
