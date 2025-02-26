```go
package main

import (
	"context"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"net/url"
	"os"
	"os/signal"
	"path/filepath"
	"syscall"
	"time"

	"github.com/gorilla/mux"
	"github.com/spf13/viper"

	"distributed-load-balancer/internal/discovery"
	"distributed-load-balancer/internal/loadbalancer"
)

// Config holds the application configuration for the load balancer.
type Config struct {
	Port                string              `mapstructure:"port"`                  // Port the load balancer listens