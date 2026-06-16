-- ==========================================================
-- The UK Digital Divide: Ofcom Connected Nations 2025
-- Author: Tejaswini Bhalerao
-- Tool: Google BigQuery SQL
-- Dataset: Ofcom Connected Nations 2025
--
-- Project Purpose:
-- Analyse broadband and mobile connectivity inequalities
-- across UK Local Authorities and identify areas of
-- digital exclusion, infrastructure gaps and high-performing
-- regions.
-- ==========================================================


-- ==========================================================
-- 1. Areas Failing the 10 Mbps Broadband Standard
--
-- Purpose:
-- Identify local authorities with the poorest broadband
-- performance relative to the UK's Universal Service
-- Obligation (USO) benchmark of 10 Mbps.
--
-- Business Insight:
-- Highlights underserved communities where broadband
-- infrastructure improvements may be required.
-- ==========================================================

SELECT
 area_name,
 dn_avg_u10 AS underserved_download_speed,
 up_avg_u10 AS underserved_upload_speed,
 ROUND(10 - dn_avg_u10, 2) AS speed_shortfall
FROM `neon-opus-493722-t3.ofcom_cn_2025.fixed_broadband_laua`
WHERE dn_avg_u10 IS NOT NULL
ORDER BY underserved_download_speed ASC
LIMIT 10;


-- ==========================================================
-- 2. Dual Connectivity Failure
--
-- Purpose:
-- Identify areas suffering from both poor fixed broadband
-- performance and weak indoor mobile coverage.
--
-- Business Insight:
-- These local authorities face heightened risk of digital
-- exclusion because residents lack reliable connectivity
-- across both fixed and mobile networks.
-- ==========================================================

SELECT
 f.area_name,
 f.dn_avg_u10 AS underserved_download_speed,
 ROUND((m.`4G_prem_in_0` / m.prem_count) * 100, 2) AS pct_no_indoor_4G,
 ROUND((m.`3G_prem_in_0` / m.prem_count) * 100, 2) AS pct_no_indoor_3G,
 ROUND(10 - f.dn_avg_u10, 2) AS fixed_speed_shortfall
FROM `neon-opus-493722-t3.ofcom_cn_2025.fixed_broadband_laua` f
JOIN `neon-opus-493722-t3.ofcom_cn_2025.mobile_coverage_laua` m
  ON f.laua_code = m.laua_code
WHERE f.dn_avg_u10 IS NOT NULL
  AND m.`4G_prem_in_0` IS NOT NULL
ORDER BY underserved_download_speed ASC
LIMIT 10;


-- ==========================================================
-- 3. Top Gigabit Speed Leaders
--
-- Purpose:
-- Identify the UK's highest-performing local authorities
-- for gigabit broadband and mobile connectivity.
--
-- Business Insight:
-- Demonstrates where advanced digital infrastructure is
-- already delivering high-speed connectivity.
-- ==========================================================

SELECT
 f.area_name,
 f.dn_avg_900plus AS gigabit_download_speed,
 f.up_avg_900plus AS gigabit_upload_speed,
 ROUND((m.`4G_prem_in_4` / m.prem_count) * 100, 2) AS pct_full_indoor_4G,
 ROUND((m.`5G_high_confidence_prem_out_4` / m.prem_count) * 100, 2) AS pct_5G_coverage
FROM `neon-opus-493722-t3.ofcom_cn_2025.fixed_broadband_laua` f
JOIN `neon-opus-493722-t3.ofcom_cn_2025.mobile_coverage_laua` m
 ON f.laua_code = m.laua_code
WHERE f.dn_avg_900plus IS NOT NULL
AND m.`4G_prem_in_4` IS NOT NULL
ORDER BY gigabit_download_speed DESC
LIMIT 10;


-- ==========================================================
-- 4. Indoor vs Outdoor 4G Coverage Gap
--
-- Purpose:
-- Compare outdoor and indoor mobile coverage to identify
-- areas where users may experience connectivity issues
-- inside homes and workplaces.
--
-- Business Insight:
-- A large indoor-outdoor gap may indicate barriers to
-- remote working, online learning and digital access.
-- ==========================================================

SELECT
 f.area_name,
 ROUND((m.`4G_prem_out_4` / m.prem_count) * 100, 2) AS pct_outdoor_4G,
 ROUND((m.`4G_prem_in_4` / m.prem_count) * 100, 2) AS pct_indoor_4G,
 ROUND(((m.`4G_prem_out_4` - m.`4G_prem_in_4`) / m.prem_count) * 100, 2) AS indoor_outdoor_gap
FROM `neon-opus-493722-t3.ofcom_cn_2025.fixed_broadband_laua` f
JOIN `neon-opus-493722-t3.ofcom_cn_2025.mobile_coverage_laua` m
 ON f.laua_code = m.laua_code
WHERE m.`4G_prem_out_4` IS NOT NULL
AND m.`4G_prem_in_4` IS NOT NULL
ORDER BY indoor_outdoor_gap DESC
LIMIT 10;


-- ==========================================================
-- 5. London Connectivity Resilience
--
-- Purpose:
-- Assess digital infrastructure resilience across major
-- London economic centres.
--
-- Business Insight:
-- Evaluates whether key business districts benefit from
-- strong fixed and mobile network infrastructure.
-- ==========================================================

SELECT
 f.area_name,
 f.up_avg_u10 AS legacy_upload_speed,
 ROUND((f.up_avg_900plus - f.up_avg_u10), 2) AS fixed_tech_gap,
 ROUND((m.`4G_prem_in_4` / m.prem_count) * 100, 2) AS pct_full_indoor_4G,
 ROUND((m.`5G_high_confidence_prem_out_4` / m.prem_count) * 100, 2) AS pct_5G_coverage
FROM `neon-opus-493722-t3.ofcom_cn_2025.fixed_broadband_laua` f
JOIN `neon-opus-493722-t3.ofcom_cn_2025.mobile_coverage_laua` m
 ON f.laua_code = m.laua_code
WHERE f.area_name IN (
 'City of London',
 'Westminster',
 'Tower Hamlets',
 'Camden',
 'Southwark',
 'Islington',
 'Hackney'
)
ORDER BY legacy_upload_speed ASC;

---
