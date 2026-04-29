package middleware

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"testing"

	"github.com/gin-gonic/gin"
)

func init() {
	gin.SetMode(gin.TestMode)
}

func setupRouter() *gin.Engine {
	r := gin.New()

	r.GET("/:sistema/test", ValidarSistema(), func(ctx *gin.Context) {
		sistema, _ := ctx.Get("sistemaValidado")
		ctx.JSON(http.StatusOK, gin.H{"sistema": sistema})
	})

	return r
}

func TestValidarSistema_Common(t *testing.T) {
	router := setupRouter()

	cases := []struct {
		descripcion    string
		sistem         string
		codigoEsperado int
	}{{"Metro es valid", "METRO", 200},
		{"MB es valida", "MB", 200},
		{"MEXIBÚS es valida", "MEXIBÚS", 200},
		{"MEXIBUS es no valida", "MEXIBUS", 404},
		{"Cadena vacia es no valida", "", 404},
		{"Numero es no valida", "1", 404}}

	for _, tc := range cases {
		t.Run(tc.descripcion, func(t *testing.T) {
			w := httptest.NewRecorder()

			req, _ := http.NewRequest("GET", "/"+tc.sistem+"/test", nil)

			router.ServeHTTP(w, req)

			if w.Code != tc.codigoEsperado {
				t.Errorf("descripcion '%s' codigoEsperado '%d' codigo '%d' ", tc.descripcion, tc.codigoEsperado, w.Code)
			}
		})
	}
}

func TestValidarSistema_ContextValue(t *testing.T) {
	router := setupRouter()

	t.Run("ToUpper es ok", func(t *testing.T) {
		w := httptest.NewRecorder()

		req, _ := http.NewRequest("GET", "/"+"metro"+"/test", nil)

		router.ServeHTTP(w, req)

		var body map[string]string

		err := json.NewDecoder(w.Body).Decode(&body)

		if err != nil {
			t.Errorf("Error al decodificar el cuerpo de la respuesta %v", err)
		}

		if body["sistema"] != "METRO" {
			t.Errorf("TopUpper no trabajo %v", body["sistema"])
		}
	})
}
