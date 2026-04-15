<?php
/**
 * Standalone WebP delivery script. Called by Apache when Accept: image/webp.
 *
 * Resolves request URI to a source image under img/ or modules/.../img or images/,
 * converts to WebP (GD/Imagick), optionally caches, and outputs with correct headers.
 * No PrestaShop bootstrap; reads optional config from config/webp_config.json.
 *
 * Input: REQUEST_URI (or path query param) set by rewrite.
 * Output: image/webp body, or 404/403.
 * Side effects: may create files in var/cache/webp/.
 */

$moduleDir = __DIR__;
$rootDir = dirname($moduleDir, 2);

$configFile = $moduleDir . '/config/webp_config.json';
$config = [
    'quality' => 82,
    'cache_enabled' => true,
];
if (is_readable($configFile)) {
    $decoded = @json_decode(file_get_contents($configFile), true);
    if (is_array($decoded)) {
        if (isset($decoded['quality']) && $decoded['quality'] >= 1 && $decoded['quality'] <= 100) {
            $config['quality'] = (int) $decoded['quality'];
        }
        if (isset($decoded['cache_enabled'])) {
            $config['cache_enabled'] = (bool) $decoded['cache_enabled'];
        }
    }
}

$requestUri = isset($_SERVER['REQUEST_URI']) ? $_SERVER['REQUEST_URI'] : '';
$path = parse_url($requestUri, PHP_URL_PATH);
$path = $path === false ? '' : trim($path, '/');

if ($path === '' || strpos($path, '..') !== false) {
    sendNotFound();
}

$allowedExtensions = ['jpg', 'jpeg', 'png', 'gif'];
$ext = strtolower(pathinfo($path, PATHINFO_EXTENSION));
if (!in_array($ext, $allowedExtensions, true)) {
    sendNotFound();
}

$sourceFile = $rootDir . '/' . $path;
if (!is_file($sourceFile) || !is_readable($sourceFile)) {
    sendNotFound();
}

$realSource = realpath($sourceFile);
$realRoot = realpath($rootDir);
if ($realSource === false || $realRoot === false || strpos($realSource, $realRoot) !== 0) {
    sendForbidden();
}

$allowedDirs = [
    $realRoot . DIRECTORY_SEPARATOR . 'img',
    $realRoot . DIRECTORY_SEPARATOR . 'modules',
];
$allowed = false;
foreach ($allowedDirs as $allowedDir) {
    if (strpos($realSource, $allowedDir) === 0) {
        $allowed = true;
        break;
    }
}
if (!$allowed) {
    sendForbidden();
}

$cacheDir = $rootDir . '/var/cache/webp';
$webpPath = null;
if ($config['cache_enabled']) {
    $hash = md5($realSource . filemtime($realSource) . $config['quality']);
    $relative = substr($path, 0, -strlen($ext)) . 'webp';
    $cacheFile = $cacheDir . '/' . $hash . '-' . preg_replace('/[^a-zA-Z0-9._-]/', '_', $relative);
    if (is_file($cacheFile) && is_readable($cacheFile)) {
        $webpPath = $cacheFile;
    }
}

if ($webpPath === null) {
    $webpBlob = convertToWebP($sourceFile, $config['quality']);
    if ($webpBlob === null) {
        sendNotFound();
    }
    if ($config['cache_enabled']) {
        if (!is_dir($cacheDir)) {
            @mkdir($cacheDir, 0755, true);
        }
        if (is_dir($cacheDir) && is_writable($cacheDir)) {
            @file_put_contents($cacheFile, $webpBlob);
            $webpPath = $cacheFile;
        }
    }
    if ($webpPath === null) {
        sendWebP($webpBlob);
        exit;
    }
}

sendWebPFile($webpPath);

function convertToWebP($sourceFile, $quality)
{
    $size = @getimagesize($sourceFile);
    if ($size === false) {
        return null;
    }
    $mime = $size['mime'] ?? '';
    $image = null;
    switch ($mime) {
        case 'image/jpeg':
            $image = @imagecreatefromjpeg($sourceFile);
            break;
        case 'image/png':
            $image = @imagecreatefrompng($sourceFile);
            if ($image) {
                imagepalettetotruecolor($image);
                imagealphablending($image, true);
                imagesavealpha($image, true);
            }
            break;
        case 'image/gif':
            $image = @imagecreatefromgif($sourceFile);
            break;
        default:
            return null;
    }
    if ($image === false) {
        return null;
    }
    if (function_exists('imagewebp')) {
        ob_start();
        if ($mime === 'image/png') {
            imagewebp($image, null, $quality);
        } else {
            imagewebp($image, null, $quality);
        }
        $blob = ob_get_clean();
        imagedestroy($image);
        return $blob !== false ? $blob : null;
    }
    if (extension_loaded('imagick')) {
        $imagick = new Imagick($sourceFile);
        $imagick->setImageFormat('webp');
        $imagick->setImageCompressionQuality($quality);
        $blob = $imagick->getImageBlob();
        $imagick->destroy();
        return $blob;
    }
    imagedestroy($image);
    return null;
}

function sendWebP($blob)
{
    header('Content-Type: image/webp');
    header('Content-Length: ' . strlen($blob));
    header('Cache-Control: public, max-age=31536000');
    header('Vary: Accept');
    echo $blob;
}

function sendWebPFile($path)
{
    header('Content-Type: image/webp');
    header('Content-Length: ' . filesize($path));
    header('Cache-Control: public, max-age=31536000');
    header('Vary: Accept');
    readfile($path);
}

function sendNotFound()
{
    header('HTTP/1.0 404 Not Found');
    exit;
}

function sendForbidden()
{
    header('HTTP/1.0 403 Forbidden');
    exit;
}
