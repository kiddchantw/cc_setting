# Secure File Upload Handling

## Validation Rules

```php
// Form Request
class UploadFileRequest extends FormRequest
{
    public function rules(): array
    {
        return [
            'file' => [
                'required',
                'file',
                'max:10240', // 10MB max
                'mimes:pdf,doc,docx,jpg,jpeg,png',
            ],
            'image' => [
                'required',
                'image',
                'max:5120', // 5MB max
                'dimensions:min_width=100,min_height=100,max_width=4000,max_height=4000',
            ],
        ];
    }
}
```

## Secure Storage

```php
class FileUploadController extends Controller
{
    public function store(UploadFileRequest $request)
    {
        $file = $request->file('file');

        // Validate extension matches content
        $extension = $file->getClientOriginalExtension();
        $mimeType = $file->getMimeType();

        if (!$this->isValidMimeForExtension($extension, $mimeType)) {
            abort(422, 'File type mismatch');
        }

        // Generate unique filename
        $filename = Str::uuid() . '.' . $extension;

        // Store outside public directory
        $path = $file->storeAs('uploads', $filename, 'private');

        // Save record
        return Document::create([
            'user_id' => auth()->id(),
            'original_name' => $file->getClientOriginalName(),
            'path' => $path,
            'mime_type' => $mimeType,
            'size' => $file->getSize(),
        ]);
    }

    private function isValidMimeForExtension(string $ext, string $mime): bool
    {
        $allowed = [
            'pdf' => ['application/pdf'],
            'jpg' => ['image/jpeg'],
            'jpeg' => ['image/jpeg'],
            'png' => ['image/png'],
            'doc' => ['application/msword'],
            'docx' => ['application/vnd.openxmlformats-officedocument.wordprocessingml.document'],
        ];

        return in_array($mime, $allowed[$ext] ?? []);
    }
}
```

## Secure Download

```php
public function download(Document $document)
{
    // Check authorization
    $this->authorize('download', $document);

    // Return file from private storage
    return Storage::disk('private')->download(
        $document->path,
        $document->original_name,
        [
            'Content-Type' => $document->mime_type,
            'Content-Disposition' => 'attachment',
        ]
    );
}
```

## Image Processing

```php
use Intervention\Image\Facades\Image;

public function uploadImage(Request $request)
{
    $request->validate([
        'image' => 'required|image|max:5120',
    ]);

    $file = $request->file('image');

    // Process image to remove EXIF data and resize
    $image = Image::make($file)
        ->orientate() // Auto-rotate based on EXIF
        ->resize(1200, 1200, function ($constraint) {
            $constraint->aspectRatio();
            $constraint->upsize();
        })
        ->encode('jpg', 80);

    $filename = Str::uuid() . '.jpg';

    Storage::disk('public')->put(
        "images/{$filename}",
        $image->stream()
    );

    return ['url' => Storage::disk('public')->url("images/{$filename}")];
}
```

## Filesystem Configuration

```php
// config/filesystems.php
'disks' => [
    'private' => [
        'driver' => 'local',
        'root' => storage_path('app/private'),
        'visibility' => 'private',
    ],

    'public' => [
        'driver' => 'local',
        'root' => storage_path('app/public'),
        'url' => env('APP_URL').'/storage',
        'visibility' => 'public',
    ],
],
```

## Security Checklist

- [ ] Validate file type by MIME and extension
- [ ] Set maximum file size limits
- [ ] Generate unique filenames (UUID)
- [ ] Store sensitive files outside public directory
- [ ] Check authorization before download
- [ ] Remove EXIF data from images
- [ ] Scan files for malware (production)
- [ ] Use signed URLs for temporary access
