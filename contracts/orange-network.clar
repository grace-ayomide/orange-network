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