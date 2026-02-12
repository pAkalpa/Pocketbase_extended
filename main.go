package main

import (
	"log"
	"net/http"
	"os"
	"strings"

	"github.com/pocketbase/pocketbase"
	"github.com/pocketbase/pocketbase/core"
)

// removeAdminDashboardLogin returns a middleware compatible with PocketBase's
// router that disables the admin dashboard routes when the environment
// variable ADMIN_ENABLED is missing, empty, or explicitly "false".
func removeAdminDashboardLogin() func(e *core.RequestEvent) error {
	return func(e *core.RequestEvent) error {
		if value, ok := os.LookupEnv("ADMIN_ENABLED"); !ok || value == "false" || len(value) == 0 {
			if strings.HasPrefix(e.Request.URL.Path, "/_/") {
				return e.NoContent(http.StatusNoContent)
			}
		}
		return e.Next()
	}
}

func main() {
	app := pocketbase.New()

	app.OnServe().BindFunc(func(se *core.ServeEvent) error {
		// register a global middleware
		se.Router.BindFunc(removeAdminDashboardLogin())
		return se.Next()
	})

	if err := app.Start(); err != nil {
		log.Fatal(err)
	}
}
