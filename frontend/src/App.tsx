```typescript
import React, { useState, useEffect, useCallback } from 'react';
import './App.css'; // Assuming a basic App.css for styling

/**
 * Interface for a registered service.
 */
interface Service {
  id: string;
  url: string;
  status: string; // e.g., "healthy", "unhealthy", "unknown"
  lastHeartbeat: string; // ISO string of the last known heartbeat
}

/**
 * Interface for the response received from the load balancer's routing endpoint.
 */
interface LoadBalancerResponse {
  message: string;
  routedTo: string; // The URL of the backend service the request was routed to
  timestamp: string;
  data?: any;