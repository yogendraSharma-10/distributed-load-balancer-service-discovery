```go
module github.com/your-org/distributed-load-balancer

go 1.21

require (
	// gorilla/mux provides a powerful URL router and dispatcher for matching incoming requests.
	// It's useful for defining API endpoints for the load balancer's control plane or admin interface.
	github.com/gorilla/mux v1.8.0

	// prometheus/client_go is the official Go client for Prometheus.
	// It allows the load balancer to expose metrics (e.g., request counts, latencies, backend health)
	// for monitoring and observability.
	github.com/prometheus/client_go v0.10.0

	// sirupsen/logrus is a structured logger for Go.
	// It provides flexible logging capabilities, essential for debugging, monitoring, and auditing
	// a production load balancer.
	github.com/sirupsen/logrus v1.9.3

	// go.etcd.io/etcd/client/v3 is the official Go client for etcd v3.
	// etcd serves as a highly available key-value store, which is critical for the
	// custom service discovery registry to store and retrieve service instances and their health status.
	go.etcd.io/etcd/client/v3 v3.5.10

	// gopkg.in/yaml.v2 is a YAML parser and emitter for Go.
	// It's used to parse the `config/balancer.yaml` file, allowing for external configuration
	// of load balancing strategies, backend services, and other operational parameters.
	gopkg.in/yaml.v2 v2.4.0
)

// The `replace` directive can be used here if you need to substitute a module
// with a local path or a different version, typically during development.
// For example:
// replace github.com/your-org/some-internal-lib => ../some-internal-lib

// The `exclude` directive can be used to prevent specific module versions
// from being used in the build.
// For example:
// exclude github.com/bad/dependency v1.2.3
```