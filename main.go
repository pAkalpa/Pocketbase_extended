package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/labstack/echo/v5"
	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

func removeAdminLogin() echo.MiddlewareFunc {
	return func(next echo.HandlerFunc) echo.HandlerFunc {
		return func(c echo.Context) error {
			if strings.HasPrefix(c.Request().URL.Path, "/_/") {
				return c.NoContent(http.StatusNoContent)
			}

			return next(c)
		}
	}
}

func main() {
	app := pocketbase.New()

	app.OnBeforeServe().Add(func(e *core.ServeEvent) error {
		if value, ok := os.LookupEnv("ADMIN_ENABLED"); !ok || value == "false" || len(value) == 0 {
			e.Router.Pre(removeAdminLogin())
		}
		return nil
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
