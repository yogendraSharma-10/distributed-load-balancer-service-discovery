```go
package discovery

import (
	"log"
	"net/http"
	"sync"
	"time"
)

// ServiceStatus represents the current health status of a service instance.
type ServiceStatus string

const (
	StatusHealthy   ServiceStatus = "HEALTHY"
	StatusUnhealthy ServiceStatus = "UNHEALTHY"
	StatusUnknown   ServiceStatus = "UNKNOWN" // Initial state or if health check failed to determine
)

// Service represents a registered backend service instance.
// It holds metadata necessary for the load balancer to route requests.
type Service struct {
	ID            string        `json:"id"`             // Unique identifier for this specific service instance (e.g., "ecommerce-api-instance-1")
	Name          string        `json:"name"`           // Logical name of the service (e.g., "ecommerce-api", "blog-service", "chat-app")
	URL           string        `json:"url"`            // Base URL of the service instance (e.g., "http://localhost:8080")
	Status        ServiceStatus `json:"status"`         // Current health status of the instance
	LastHeartbeat time.Time     `json:"last_heartbeat"` // Timestamp of the last successful heartbeat received
	RegisteredAt  time.Time     `json:"registered_at"`  // Timestamp when the service was first registered
}

// ServiceRegistry manages the registration, deregistration, and health checking
// of backend service instances. It provides a centralized source of truth
// for available services to the load balancer.
type ServiceRegistry struct {
	services map[string]*Service // Map of service ID to Service object
	mu       sync.RWMutex        // Mutex to protect concurrent access to the services map
	stopChan chan struct{}       // Channel to signal the health check goroutine to stop
}

// NewServiceRegistry creates and returns a new ServiceRegistry instance.
func NewServiceRegistry() *ServiceRegistry {
	return &ServiceRegistry{
		services: make(map[string]*Service),
		stopChan: make(chan struct{}),
	}
}

// Register adds a new service instance or updates an existing one in the registry.
// If a service with the given ID already exists, its details (Name, URL) and heartbeat
// are updated. Its status is reset to Unknown to trigger a fresh health check.
// It returns true if the service was newly registered, false if updated.
func (sr *ServiceRegistry) Register(serviceID, serviceName, serviceURL string) (bool, error) {
	sr.mu.Lock()
	defer sr.mu.Unlock()

	now := time.Now()
	isNew := false

	if service, exists := sr.services[serviceID]; exists {
		// Update existing service instance
		