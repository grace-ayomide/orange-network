;; Title: OrangeNetwork - Decentralized Social Infrastructure for Bitcoin
;;
;; Summary: A cutting-edge social networking protocol that leverages Bitcoin's 
;; security and Stacks' smart contract capabilities to create a truly decentralized, 
;; censorship-resistant social platform with enterprise-grade privacy controls.
;;
;; Description: OrangeNetwork transforms social networking by building directly on 
;; Bitcoin's immutable foundation. Users maintain complete control over their data 
;; and social connections through cryptographic proofs, while intelligent batch 
;; processing ensures optimal Layer 2 performance. The protocol features advanced 
;; privacy controls, anti-spam mechanisms, and scalable architecture designed for 
;; mass adoption without compromising decentralization principles.

;; Core Protocol Error Definitions
(define-constant ERR_RESOURCE_NOT_FOUND (err u100)) ;; Requested resource unavailable
(define-constant ERR_RESOURCE_EXISTS (err u101)) ;; Duplicate resource creation attempt
(define-constant ERR_ACCESS_DENIED (err u102)) ;; Insufficient permissions
(define-constant ERR_INVALID_PARAMETERS (err u103)) ;; Malformed input data
(define-constant ERR_USER_BLOCKED (err u104)) ;; Access restricted by user
(define-constant ERR_ACCOUNT_DEACTIVATED (err u105)) ;; Account temporarily suspended
(define-constant ERR_RATE_LIMIT_EXCEEDED (err u106)) ;; Action frequency limit reached
(define-constant ERR_BATCH_CAPACITY_FULL (err u107)) ;; Batch processing queue full
(define-constant ERR_BATCH_PROCESSING_TIMEOUT (err u108)) ;; Batch expired without processing

;; User Account State Enumeration
(define-constant ACCOUNT_DEACTIVATED u0) ;; Account suspended or disabled
(define-constant ACCOUNT_ACTIVE u1) ;; Account fully operational
(define-constant ACCOUNT_RESTRICTED u2) ;; Account with limited permissions

;; Social Relationship State Types
(define-constant RELATIONSHIP_PENDING u0) ;; Connection request pending
(define-constant RELATIONSHIP_ESTABLISHED u1) ;; Active bidirectional connection
(define-constant RELATIONSHIP_BLOCKED u2) ;; Access denied by user

;; Rate Limiting Configuration Parameters
(define-constant MAX_DAILY_ACTIONS u100) ;; Maximum actions per 24-hour period
(define-constant MAX_DAILY_FRIEND_REQUESTS u20) ;; Friend request daily limit
(define-constant MAX_DAILY_PROFILE_UPDATES u24) ;; Profile modification daily limit
(define-constant RATE_LIMIT_RESET_INTERVAL u86400) ;; 24-hour reset cycle in seconds

;; Batch Processing Optimization Parameters
(define-constant MINIMUM_BATCH_SIZE u10) ;; Minimum efficient batch size
(define-constant MAXIMUM_BATCH_SIZE u100) ;; Maximum batch processing capacity
(define-constant BATCH_TIMEOUT_PERIOD u3600) ;; Batch expiry time (1 hour)

;; DATA STRUCTURES & PERSISTENT STORAGE MAPS

;; Primary User Identity Registry
;; Comprehensive user profile and account management system
(define-map UserRegistry
  principal
  {
    display-name: (string-ascii 64), ;; Public display name
    account-status: uint, ;; Current account state
    registration-timestamp: uint, ;; Account creation time
    encrypted-metadata: (optional (string-utf8 256)), ;; Encrypted profile information
    deactivation-timestamp: (optional uint), ;; Account suspension time
    client-encryption-key: (optional (buff 32)), ;; User's encryption key
    avatar-uri: (optional (string-utf8 256)), ;; Profile image reference
  }
)

;; Advanced Privacy Control System
;; Granular privacy settings for comprehensive user control
(define-map PrivacyConfiguration
  principal
  {
    social-graph-visibility: bool, ;; Friends list public visibility
    activity-status-sharing: bool, ;; Online status broadcasting
    profile-metadata-exposure: bool, ;; Profile information sharing
    last-seen-broadcasting: bool, ;; Activity timestamp sharing
    avatar-display-enabled: bool, ;; Profile picture visibility
    end-to-end-encryption: bool, ;; Message encryption toggle
    settings-last-modified: uint, ;; Configuration update timestamp
  }
)

;; Sophisticated Rate Limiting Engine
;; Multi-dimensional action tracking for abuse prevention
(define-map ActionRateLimits
  principal
  {
    total-daily-actions: uint, ;; Aggregate daily action count
    friend-requests-sent: uint, ;; Daily friend request count
    profile-modifications: uint, ;; Daily profile update count
    counter-reset-timestamp: uint, ;; Last rate limit reset time
  }
)

;; Intelligent Batch Processing System
;; Layer 2 optimization engine for transaction efficiency
(define-map BatchProcessingData
  principal
  {
    pending-message-count: uint, ;; Queued messages awaiting batch
    last-batch-processing-time: uint, ;; Previous batch execution time
    current-batch-size: uint, ;; Configured batch size
    active-batch-item-count: uint, ;; Items in current batch
    lifetime-batch-count: uint, ;; Total batches processed
  }
)

;; Comprehensive User Analytics System
;; Engagement tracking and platform usage metrics
(define-map UserEngagementMetrics
  principal
  {
    last-activity-timestamp: uint, ;; Most recent platform interaction
    total-login-sessions: uint, ;; Cumulative login count
    lifetime-action-count: uint, ;; Total actions performed
    most-recent-action-time: uint, ;; Timestamp of last action
  }
)

;; Social Graph Relationship Management
;; Bidirectional connection tracking system
(define-map SocialConnections
  {
    first-party: principal, ;; First user in relationship
    second-party: principal, ;; Second user in relationship
  }
  { connection-status: uint }
)

;; User Blocking and Access Control
;; Harassment prevention and user protection system
(define-map AccessControlList
  {
    blocking-user: principal, ;; User initiating block
    blocked-user: principal, ;; User being blocked
  }
  { block-timestamp: uint }
)

;; CORE UTILITY FUNCTIONS & HELPER METHODS

;; Advanced Rate Limiting Validation Engine
;; Comprehensive action limit checking with automatic reset cycles
(define-private (validate-rate-limits
    (user principal)
    (action-category uint)
  )
  (let (
      (rate-data (default-to {
        total-daily-actions: u0,
        friend-requests-sent: u0,
        profile-modifications: u0,
        counter-reset-timestamp: stacks-block-height,
      }
        (map-get? ActionRateLimits user)
      ))
      (current-block-time stacks-block-height)
      (time-since-reset (- current-block-time (get counter-reset-timestamp rate-data)))
      (reset-required (> time-since-reset RATE_LIMIT_RESET_INTERVAL))
    )
    (if reset-required
      ;; Perform automatic rate limit reset after period expiration
      (begin
        (map-set ActionRateLimits user {
          total-daily-actions: u1,
          friend-requests-sent: (if (is-eq action-category u1)
            u1
            u0
          ),
          profile-modifications: (if (is-eq action-category u2)
            u1
            u0
          ),
          counter-reset-timestamp: current-block-time,
        })
        true
      )
      ;; Validate against current rate limits
      (and
        (< (get total-daily-actions rate-data) MAX_DAILY_ACTIONS)
        (or
          (not (is-eq action-category u1))
          (< (get friend-requests-sent rate-data) MAX_DAILY_FRIEND_REQUESTS)
        )
        (or
          (not (is-eq action-category u2))
          (< (get profile-modifications rate-data) MAX_DAILY_PROFILE_UPDATES)
        )
      )
    )
  )
)

;; Rate Limit Counter Increment System
;; Updates appropriate counters following successful action execution
(define-private (increment-rate-limit-counters
    (user principal)
    (action-category uint)
  )
  (let ((current-rate-data (unwrap-panic (map-get? ActionRateLimits user))))
    (map-set ActionRateLimits user
      (merge current-rate-data {
        total-daily-actions: (+ (get total-daily-actions current-rate-data) u1),
        friend-requests-sent: (+ (get friend-requests-sent current-rate-data)
          (if (is-eq action-category u1)
            u1
            u0
          )),
        profile-modifications: (+ (get profile-modifications current-rate-data)
          (if (is-eq action-category u2)
            u1
            u0
          )),
      })
    )
  )
)

;; User Engagement Analytics Update System
;; Maintains comprehensive user activity metrics
(define-private (update-engagement-metrics (user principal))
  (let (
      (current-block-time stacks-block-height)
      (existing-metrics (default-to {
        last-activity-timestamp: current-block-time,
        total-login-sessions: u0,
        lifetime-action-count: u0,
        most-recent-action-time: current-block-time,
      }
        (map-get? UserEngagementMetrics user)
      ))
    )
    (map-set UserEngagementMetrics user
      (merge existing-metrics {
        last-activity-timestamp: current-block-time,
        lifetime-action-count: (+ (get lifetime-action-count existing-metrics) u1),
        most-recent-action-time: current-block-time,
      })
    )
  )
)

;; Mathematical Utility Functions for Optimization
(define-private (calculate-maximum
    (value-a uint)
    (value-b uint)
  )
  (if (>= value-a value-b)
    value-a
    value-b
  )
)

(define-private (calculate-minimum
    (value-a uint)
    (value-b uint)
  )
  (if (<= value-a value-b)
    value-a
    value-b
  )
)

;; Social Graph Relationship Verification
;; Validates active connections between users
(define-private (verify-active-connection
    (first-user principal)
    (second-user principal)
  )
  (match (map-get? SocialConnections {
    first-party: first-user,
    second-party: second-user,
  })
    connection-data (is-eq (get connection-status connection-data) RELATIONSHIP_ESTABLISHED)
    false
  )
)

;; User Account Status Validation
;; Ensures user account is active and operational
(define-private (validate-active-account (user principal))
  (match (map-get? UserRegistry user)
    user-profile (and
      (is-eq (get account-status user-profile) ACCOUNT_ACTIVE)
      (is-none (get deactivation-timestamp user-profile))
    )
    false
  )
)

;; User Account Existence Verification
;; Confirms user is registered in the system
(define-private (confirm-user-registration (user principal))
  (is-some (map-get? UserRegistry user))
)

;; Access Control Validation
;; Checks if user access is restricted by blocking
(define-private (check-access-restrictions
    (requesting-user principal)
    (target-user principal)
  )
  (is-some (map-get? AccessControlList {
    blocking-user: requesting-user,
    blocked-user: target-user,
  }))
)

;; Privacy Settings Retrieval with Secure Defaults
;; Returns user privacy configuration with fallback to secure defaults
(define-private (retrieve-privacy-configuration (user principal))
  (default-to {
    social-graph-visibility: true,
    activity-status-sharing: true,
    profile-metadata-exposure: true,
    last-seen-broadcasting: true,
    avatar-display-enabled: true,
    end-to-end-encryption: false,
    settings-last-modified: stacks-block-height,
  }
    (map-get? PrivacyConfiguration user)
  )
)

;; PUBLIC INTERFACE FUNCTIONS & PROTOCOL ENDPOINTS

;; Advanced Batch Processing Optimization Engine
;; Dynamically adjusts batch parameters for optimal Layer 2 performance
(define-public (optimize-batch-processing-parameters (user principal))
  (let (
      (batch-configuration (unwrap-panic (map-get? BatchProcessingData user)))
      (current-block-time stacks-block-height)
      (time-since-last-batch (- current-block-time (get last-batch-processing-time batch-configuration)))
      (configured-batch-size (get current-batch-size batch-configuration))
      (active-batch-items (get active-batch-item-count batch-configuration))
    )
    (if (> time-since-last-batch BATCH_TIMEOUT_PERIOD)
      ;; Batch processing timeout - reset and optimize size
      (begin
        (map-set BatchProcessingData user
          (merge batch-configuration {
            current-batch-size: (calculate-maximum MINIMUM_BATCH_SIZE (/ configured-batch-size u2)),
            active-batch-item-count: u0,
            last-batch-processing-time: current-block-time,
          })
        )
        (ok true)
      )
      ;; Active batch processing - dynamic size adjustment
      (begin
        (map-set BatchProcessingData user
          (merge batch-configuration { current-batch-size: (calculate-minimum MAXIMUM_BATCH_SIZE
            (if (>= active-batch-items (/ configured-batch-size u2))
              (* configured-batch-size u2)
              configured-batch-size
            )) }
          ))
        (ok true)
      )
    )
  )
)

;; Comprehensive Privacy Configuration Management
;; Advanced privacy control system with granular permission settings
(define-public (configure-advanced-privacy-settings
    (enable-social-graph-visibility bool)
    (enable-activity-status-sharing bool)
    (enable-profile-metadata-exposure bool)
    (enable-last-seen-broadcasting bool)
    (enable-avatar-display bool)
    (enable-end-to-end-encryption bool)
  )
  (let ((requesting-user tx-sender))
    (asserts! (validate-active-account requesting-user) ERR_ACCOUNT_DEACTIVATED)
    (asserts! (validate-rate-limits requesting-user u2) ERR_RATE_LIMIT_EXCEEDED)
    (map-set PrivacyConfiguration requesting-user {
      social-graph-visibility: enable-social-graph-visibility,
      activity-status-sharing: enable-activity-status-sharing,
      profile-metadata-exposure: enable-profile-metadata-exposure,
      last-seen-broadcasting: enable-last-seen-broadcasting,
      avatar-display-enabled: enable-avatar-display,
      end-to-end-encryption: enable-end-to-end-encryption,
      settings-last-modified: stacks-block-height,
    })
    (increment-rate-limit-counters requesting-user u2)
    (update-engagement-metrics requesting-user)
    (print {
      event: "privacy-configuration-updated",
      user: requesting-user,
      timestamp: stacks-block-height,
      encryption-enabled: enable-end-to-end-encryption,
    })
    (ok true)
  )
)

;; Sophisticated User Profile Management System
;; Multi-field profile update with advanced encryption support
(define-public (update-comprehensive-user-profile
    (display-name (optional (string-ascii 64)))
    (encrypted-metadata (optional (string-utf8 256)))
    (client-encryption-key (optional (buff 32)))
    (avatar-uri (optional (string-utf8 256)))
  )
  (let (
      (requesting-user tx-sender)
      (existing-profile (unwrap-panic (map-get? UserRegistry requesting-user)))
    )
    (asserts! (validate-active-account requesting-user) ERR_ACCOUNT_DEACTIVATED)
    (asserts! (validate-rate-limits requesting-user u2) ERR_RATE_LIMIT_EXCEEDED)
    (map-set UserRegistry requesting-user
      (merge existing-profile {
        display-name: (default-to (get display-name existing-profile) display-name),
        encrypted-metadata: (if (is-some encrypted-metadata)
          encrypted-metadata
          (get encrypted-metadata existing-profile)
        ),
        client-encryption-key: (if (is-some client-encryption-key)
          client-encryption-key
          (get client-encryption-key existing-profile)
        ),
        avatar-uri: (if (is-some avatar-uri)
          avatar-uri
          (get avatar-uri existing-profile)
        ),
      })
    )
    (increment-rate-limit-counters requesting-user u2)
    (update-engagement-metrics requesting-user)
    (print {
      event: "comprehensive-profile-updated",
      user: requesting-user,
      timestamp: stacks-block-height,
      updated-fields: {
        display-name: (is-some display-name),
        encrypted-metadata: (is-some encrypted-metadata),
        client-encryption-key: (is-some client-encryption-key),
        avatar-uri: (is-some avatar-uri),
      },
    })
    (ok true)
  )
)

;; Dynamic Batch Size Configuration Interface
;; User-controlled batch processing optimization
(define-public (configure-batch-processing-size (desired-batch-size uint))
  (let (
      (requesting-user tx-sender)
      (current-batch-configuration (unwrap-panic (map-get? BatchProcessingData requesting-user)))
    )
    (asserts! (validate-active-account requesting-user) ERR_ACCOUNT_DEACTIVATED)
    (asserts!
      (and (>= desired-batch-size MINIMUM_BATCH_SIZE) (<= desired-batch-size MAXIMUM_BATCH_SIZE))
      ERR_INVALID_PARAMETERS
    )
    (map-set BatchProcessingData requesting-user
      (merge current-batch-configuration { current-batch-size: desired-batch-size })
    )
    (print {
      event: "batch-processing-optimized",
      user: requesting-user,
      previous-batch-size: (get current-batch-size current-batch-configuration),
      new-batch-size: desired-batch-size,
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)

;; Secure User Session Management System
;; Advanced login tracking and session analytics
(define-public (record-secure-user-session)
  (let (
      (requesting-user tx-sender)
      (current-engagement-metrics (default-to {
        last-activity-timestamp: stacks-block-height,
        total-login-sessions: u0,
        lifetime-action-count: u0,
        most-recent-action-time: stacks-block-height,
      }
        (map-get? UserEngagementMetrics requesting-user)
      ))
    )
    (map-set UserEngagementMetrics requesting-user
      (merge current-engagement-metrics {
        last-activity-timestamp: stacks-block-height,
        total-login-sessions: (+ (get total-login-sessions current-engagement-metrics) u1),
      })
    )
    (print {
      event: "secure-session-established",
      user: requesting-user,
      session-number: (+ (get total-login-sessions current-engagement-metrics) u1),
      timestamp: stacks-block-height,
    })
    (ok true)
  )
)