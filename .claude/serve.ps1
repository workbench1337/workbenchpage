# Tiny static file server for local preview (no Python/Node needed)
$root = Split-Path -Parent $PSScriptRoot
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add('http://localhost:8765/')
$l.Start()
Write-Host "Serving $root on http://localhost:8765/"
$types = @{ '.html'='text/html; charset=utf-8'; '.mp3'='audio/mpeg'; '.json'='application/json'; '.js'='text/javascript'; '.css'='text/css' }
while ($l.IsListening) {
  $c = $l.GetContext()
  $p = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/'))
  if ($p -eq '') { $p = 'index.html' }
  $f = Join-Path $root $p
  try {
    if (Test-Path -LiteralPath $f -PathType Leaf) {
      $b = [IO.File]::ReadAllBytes($f)
      $ext = [IO.Path]::GetExtension($f).ToLower()
      if ($types.ContainsKey($ext)) { $c.Response.ContentType = $types[$ext] }
      $c.Response.ContentLength64 = $b.Length
      $c.Response.OutputStream.Write($b, 0, $b.Length)
    } else { $c.Response.StatusCode = 404 }
  } catch {}
  $c.Response.Close()
}
