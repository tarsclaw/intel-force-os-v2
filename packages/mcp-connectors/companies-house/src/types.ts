// TypeScript types for Companies House REST API responses.
// Aligned with https://developer.company-information.service.gov.uk/api/reference
// (verified 2026-05-24; partial shape — only fields we consume).

export interface CHSearchResult {
  readonly company_number: string;
  readonly title: string;
  readonly company_status: string;
  readonly date_of_creation?: string;
  readonly address_snippet?: string;
  readonly description?: string;
}

export interface CHSearchResponse {
  readonly items: CHSearchResult[];
  readonly total_results: number;
  readonly start_index: number;
  readonly items_per_page: number;
}

export interface CHAddress {
  readonly address_line_1?: string;
  readonly address_line_2?: string;
  readonly locality?: string;
  readonly postal_code?: string;
  readonly country?: string;
}

export interface CHProfile {
  readonly company_number: string;
  readonly company_name: string;
  readonly company_status: string;
  readonly date_of_creation: string;
  readonly type: string;
  readonly registered_office_address: CHAddress;
  readonly accounts?: {
    readonly last_accounts?: {
      readonly made_up_to?: string;
      readonly type?: string;
    };
    readonly next_due?: string;
  };
  readonly sic_codes?: string[];
  readonly jurisdiction?: string;
}

export interface CHOfficer {
  readonly name: string;
  readonly officer_role: string;
  readonly appointed_on?: string;
  readonly resigned_on?: string;
  readonly occupation?: string;
  readonly date_of_birth?: { readonly month: number; readonly year: number };
  readonly country_of_residence?: string;
  readonly nationality?: string;
}

export interface CHOfficersResponse {
  readonly items: CHOfficer[];
  readonly total_results: number;
  readonly active_count?: number;
  readonly resigned_count?: number;
}

export interface CHFiling {
  readonly category: string;
  readonly description: string;
  readonly date: string;
  readonly type: string;
  readonly action_date?: string;
}

export interface CHFilingHistoryResponse {
  readonly items: CHFiling[];
  readonly total_count: number;
  readonly start_index: number;
  readonly items_per_page: number;
}
