;; Collab Chain Matrix

;; =========================================
;; ERROR CODES AND FOUNDATIONAL DEFINITIONS
;; =========================================

(define-constant ERR-VALIDATION-FAILED-GEOGRAPHY (err u401))
(define-constant ERR-VALIDATION-FAILED-BIOGRAPHY (err u402))
(define-constant ERR-VALIDATION-FAILED-OPPORTUNITY (err u403))
(define-constant ERR-ENTRY-NONEXISTENT (err u404))

(define-constant ERR-ENTITY-MISSING (err u404))
(define-constant ERR-DUPLICATE-ENTRY (err u409))
(define-constant ERR-VALIDATION-FAILED-NAME (err u400))

;; ================================================
;; PERSISTENT DATA STRUCTURES FOR THE NEXUS SYSTEM
;; ================================================


;; Enterprise repository - stores business entities and characteristics
(define-map enterprise-repository
    principal
    {
        business-name: (string-ascii 100),
        sector: (string-ascii 50),
        geography: (string-ascii 100)
    }
)

;; Opportunity repository - stores project offerings and collaborations
(define-map opportunity-repository
    principal
    {
        heading: (string-ascii 100),
        narrative: (string-ascii 500),
        originator: principal,
        geography: (string-ascii 100),
        prerequisites: (list 10 (string-ascii 50))
    }
)

;; Talent repository - stores professional identities and their attributes
(define-map talent-repository
    principal
    {
        identity-label: (string-ascii 100),
        proficiencies: (list 10 (string-ascii 50)),
        geography: (string-ascii 100),
        biography: (string-ascii 500)
    }
)


;; =============================================
;; INFORMATION RETRIEVAL AND QUERY FUNCTIONS
;; =============================================

;; Extract specific opportunity details from the repository
(define-read-only (fetch-opportunity-data (opportunity-id principal))
    (match (map-get? opportunity-repository opportunity-id)
        opportunity-record (ok opportunity-record)
        ERR-ENTITY-MISSING
    )
)

;; =============================================
;; TALENT IDENTITY MANAGEMENT FUNCTIONS
;; =============================================


;; Update an existing professional's attributes and capabilities
(define-public (revise-talent-identity 
    (identity-label (string-ascii 100))
    (proficiencies (list 10 (string-ascii 50)))
    (geography (string-ascii 100))
    (biography (string-ascii 500)))
    (let
        (
            (operator tx-sender)
            (existing-identity (map-get? talent-repository operator))
        )
        ;; Verify this professional exists in system
        (if (is-some existing-identity)
            (begin
                ;; Validate all required information fields
                (if (or (is-eq identity-label "")
                        (is-eq geography "")
                        (is-eq (len proficiencies) u0)
                        (is-eq biography ""))
                    (err ERR-VALIDATION-FAILED-BIOGRAPHY)
                    (begin
                        ;; Update the talent repository with revised information
                        (map-set talent-repository operator
                            {
                                identity-label: identity-label,
                                proficiencies: proficiencies,
                                geography: geography,
                                biography: biography
                            }
                        )
                        (ok "Professional identity successfully revised in TalentNexus.")
                    )
                )
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

;; Initialize a new professional identity in the ecosystem
(define-public (establish-talent-identity 
    (identity-label (string-ascii 100))
    (proficiencies (list 10 (string-ascii 50)))
    (geography (string-ascii 100))
    (biography (string-ascii 500)))
    (let
        (
            (operator tx-sender)
            (existing-identity (map-get? talent-repository operator))
        )
        ;; Verify this professional isn't already registered
        (if (is-none existing-identity)
            (begin
                ;; Ensure all required fields meet validation criteria
                (if (or (is-eq identity-label "")
                        (is-eq geography "")
                        (is-eq (len proficiencies) u0)
                        (is-eq biography ""))
                    (err ERR-VALIDATION-FAILED-BIOGRAPHY)
                    (begin
                        ;; Commit the talent profile to the repository
                        (map-set talent-repository operator
                            {
                                identity-label: identity-label,
                                proficiencies: proficiencies,
                                geography: geography,
                                biography: biography
                            }
                        )
                        (ok "Professional identity successfully established in TalentNexus.")
                    )
                )
            )
            (err ERR-DUPLICATE-ENTRY)
        )
    )
)

;; Remove a professional from the talent ecosystem
(define-public (dissolve-talent-identity)
    (let
        (
            (operator tx-sender)
            (existing-identity (map-get? talent-repository operator))
        )
        ;; Verify this professional exists in system
        (if (is-some existing-identity)
            (begin
                ;; Purge the talent identity from repository
                (map-delete talent-repository operator)
                (ok "Professional identity successfully removed from TalentNexus.")
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

;; ==========================================
;; ENTERPRISE ENTITY MANAGEMENT FUNCTIONS
;; ==========================================

;; Register a new business entity in the ecosystem
(define-public (establish-enterprise-presence 
    (business-name (string-ascii 100))
    (sector (string-ascii 50))
    (geography (string-ascii 100)))
    (let
        (
            (operator tx-sender)
            (existing-entity (map-get? enterprise-repository operator))
        )
        ;; Verify no duplicate enterprise entity
        (if (is-none existing-entity)
            (begin
                ;; Validate required enterprise information
                (if (or (is-eq business-name "")
                        (is-eq sector "")
                        (is-eq geography ""))
                    (err ERR-VALIDATION-FAILED-GEOGRAPHY)
                    (begin
                        ;; Commit enterprise entity to repository
                        (map-set enterprise-repository operator
                            {
                                business-name: business-name,
                                sector: sector,
                                geography: geography
                            }
                        )
                        (ok "Enterprise entity successfully registered in TalentNexus.")
                    )
                )
            )
            (err ERR-DUPLICATE-ENTRY)
        )
    )
)

;; Update an existing enterprise entity's attributes
(define-public (revise-enterprise-presence 
    (business-name (string-ascii 100))
    (sector (string-ascii 50))
    (geography (string-ascii 100)))
    (let
        (
            (operator tx-sender)
            (existing-entity (map-get? enterprise-repository operator))
        )
        ;; Verify enterprise exists in system
        (if (is-some existing-entity)
            (begin
                ;; Validate required enterprise fields
                (if (or (is-eq business-name "")
                        (is-eq sector "")
                        (is-eq geography ""))
                    (err ERR-VALIDATION-FAILED-GEOGRAPHY)
                    (begin
                        ;; Update enterprise information in repository
                        (map-set enterprise-repository operator
                            {
                                business-name: business-name,
                                sector: sector,
                                geography: geography
                            }
                        )
                        (ok "Enterprise entity successfully updated in TalentNexus.")
                    )
                )
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

;; Remove an enterprise entity from the ecosystem
(define-public (dissolve-enterprise-presence)
    (let
        (
            (operator tx-sender)
            (existing-entity (map-get? enterprise-repository operator))
        )
        ;; Verify enterprise exists in system
        (if (is-some existing-entity)
            (begin
                ;; Purge enterprise from repository
                (map-delete enterprise-repository operator)
                (ok "Enterprise entity successfully removed from TalentNexus.")
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

;; ==============================================
;; OPPORTUNITY MANAGEMENT AND CURATION FUNCTIONS
;; ==============================================

;; Publish a new opportunity to the nexus ecosystem
(define-public (broadcast-opportunity 
    (heading (string-ascii 100))
    (narrative (string-ascii 500))
    (geography (string-ascii 100))
    (prerequisites (list 10 (string-ascii 50))))
    (let
        (
            (operator tx-sender)
            (existing-opportunity (map-get? opportunity-repository operator))
        )
        ;; Verify no existing opportunity by this publisher
        (if (is-none existing-opportunity)
            (begin
                ;; Validate opportunity required fields
                (if (or (is-eq heading "")
                        (is-eq narrative "")
                        (is-eq geography "")
                        (is-eq (len prerequisites) u0))
                    (err ERR-VALIDATION-FAILED-OPPORTUNITY)
                    (begin
                        ;; Create the opportunity in repository
                        (map-set opportunity-repository operator
                            {
                                heading: heading,
                                narrative: narrative,
                                originator: operator,
                                geography: geography,
                                prerequisites: prerequisites
                            }
                        )
                        (ok "Opportunity successfully broadcast to TalentNexus.")
                    )
                )
            )
            (err ERR-DUPLICATE-ENTRY)
        )
    )
)

;; Revise an existing opportunity in the ecosystem
(define-public (refine-opportunity 
    (heading (string-ascii 100))
    (narrative (string-ascii 500))
    (geography (string-ascii 100))
    (prerequisites (list 10 (string-ascii 50))))
    (let
        (
            (operator tx-sender)
            (existing-opportunity (map-get? opportunity-repository operator))
        )
        ;; Verify opportunity exists
        (if (is-some existing-opportunity)
            (begin
                ;; Validate opportunity fields
                (if (or (is-eq heading "")
                        (is-eq narrative "")
                        (is-eq geography "")
                        (is-eq (len prerequisites) u0))
                    (err ERR-VALIDATION-FAILED-OPPORTUNITY)
                    (begin
                        ;; Update the opportunity in repository
                        (map-set opportunity-repository operator
                            {
                                heading: heading,
                                narrative: narrative,
                                originator: operator,
                                geography: geography,
                                prerequisites: prerequisites
                            }
                        )
                        (ok "Opportunity successfully refined in TalentNexus.")
                    )
                )
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

;; Withdraw an opportunity from the ecosystem
(define-public (withdraw-opportunity)
    (let
        (
            (operator tx-sender)
            (existing-opportunity (map-get? opportunity-repository operator))
        )
        ;; Verify opportunity exists
        (if (is-some existing-opportunity)
            (begin
                ;; Remove opportunity from repository
                (map-delete opportunity-repository operator)
                (ok "Opportunity successfully withdrawn from TalentNexus.")
            )
            (err ERR-ENTRY-NONEXISTENT)
        )
    )
)

