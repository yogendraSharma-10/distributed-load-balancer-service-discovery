```go
package loadbalancer

import (
	"errors"
	"math/rand"
	"sync"
	"time"

	"github.com/your-org/your-project/internal/discovery" // Adjust import path as per your project structure
)

// ErrNoHealthyInstances is returned when no healthy service instances are available for selection.
var ErrNoHealthyInstances = errors.New("no healthy service instances available")

// LoadBalancingStrategy defines the interface for different load balancing algorithms.
type LoadBalancingStrategy interface {
	// Next selects the next service instance from the provided list based on the strategy.
	// It should only consider healthy instances.
	// Returns the selected instance or an error if no healthy instances are available