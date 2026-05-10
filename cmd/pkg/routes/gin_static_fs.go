package routes

import (
	"net/http"
	"path"
	"strings"
)

// ginStaticFileSystem wraps an http.FileSystem so it works with gin.StaticFS over embed / io/fs.
//
// Gin passes *filepath wildcard values with a leading slash (e.g. "/map/index.html"), and
// directory requests may end with "/". io/fs requires fs.ValidPath names: no leading or trailing
// slashes (except the special "." root). Without normalization, gin's preliminary Open fails
// with 404 and nested static files never load.
type ginStaticFileSystem struct{ inner http.FileSystem }

func ginStaticFS(inner http.FileSystem) http.FileSystem {
	return ginStaticFileSystem{inner: inner}
}

func (g ginStaticFileSystem) Open(name string) (http.File, error) {
	name = strings.TrimLeft(name, "/")
	name = strings.TrimPrefix(path.Clean("/"+name), "/")
	if name == "" {
		name = "."
	}
	return g.inner.Open(name)
}
