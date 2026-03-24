-- =============================================================================
-- Données de démonstration « vitrine » — société fictive
-- Base PostgreSQL (aligné sur Prisma / schema.prisma)
-- Période factures : 01/12/2025 au 31/03/2026
-- NCC clients / fournisseurs / société : entièrement fictifs, format 7 chiffres + 1 lettre majuscule (ex. 1234567K)
--
-- IMPORTANT : exécuter sur une base de test. Vérifier les IDs si doublons.
-- Mot de passe utilisateur démo (login) : DemoVitrine2025
--
-- Pour une démo massive (1200 ventes, 800 achats, 100 clients, 50 fournisseurs),
-- préférer le script Node : backend/prisma/seed-vitrine-bulk.ts (npm run seed:vitrine).
-- =============================================================================

BEGIN;

-- Extensions utiles pour UUID (si besoin)
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -----------------------------------------------------------------------------
-- 1) Société, établissement, point de vente, abonnement, utilisateur
-- -----------------------------------------------------------------------------

INSERT INTO "Company" ("id", "ncc", "name", "createdAt", "updatedAt")
VALUES (
  '11111111-1111-1111-1111-111111111101',
  '9012345V',
  'Société Démo Vitrine SARL',
  NOW(),
  NOW()
)
ON CONFLICT ("ncc") DO NOTHING;

INSERT INTO "Establishment" ("id", "companyId", "externalId", "name", "createdAt", "updatedAt")
VALUES (
  '11111111-1111-1111-1111-111111111102',
  '11111111-1111-1111-1111-111111111101',
  'FNE-EST-DEMO-001',
  'Siège Démo — Abidjan',
  NOW(),
  NOW()
)
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "PointOfSale" ("id", "establishmentId", "name", "slug", "isActive", "createdAt", "updatedAt")
VALUES (
  '11111111-1111-1111-1111-111111111103',
  '11111111-1111-1111-1111-111111111102',
  'Boutique Démo Plateau',
  'demo-plateau',
  TRUE,
  NOW(),
  NOW()
)
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "Subscription" ("id", "companyId", "startDate", "endDate", "price", "createdAt", "updatedAt")
VALUES (
  '11111111-1111-1111-1111-111111111105',
  '11111111-1111-1111-1111-111111111101',
  '2025-12-01'::timestamp,
  '2027-12-31'::timestamp,
  0.00,
  NOW(),
  NOW()
)
ON CONFLICT ("companyId") DO NOTHING;

-- Hash bcrypt pour le mot de passe : DemoVitrine2025
INSERT INTO "User" (
  "id", "username", "password", "email", "role", "accessRights",
  "firstName", "lastName", "companyId", "pointOfSale", "createdAt", "updatedAt"
)
VALUES (
  '11111111-1111-1111-1111-111111111104',
  'demo.vitrine',
  '$2b$10$o8lrz52JbY4LtnH27d1U8uJ6IyUTGUZEuRB9F/OPAaQYI0estx7eu',
  'demo.vitrine@demo-fne-dashboard.local',
  'admin',
  'dashboard,sales,purchases,import,export,reports,configuration',
  'Démo',
  'Utilisateur',
  '11111111-1111-1111-1111-111111111101',
  'ALL',
  NOW(),
  NOW()
)
ON CONFLICT ("username") DO NOTHING;

-- -----------------------------------------------------------------------------
-- 2) Factures de vente (émissions) — clients NCC fictifs
--    subtype : normal | refund ; avoirs avec parentReference
-- -----------------------------------------------------------------------------

-- Ventes « normal »
INSERT INTO "InvoiceSales" (
  "id", "reference", "parentReference", "subtype", "date", "paymentMethod",
  "clientNcc", "clientName", "companyId", "companyName", "establishmentId", "establishmentName",
  "pointOfSaleId", "pointOfSaleName", "totalTva", "totalTtc", "totalDiscount", "totalBeforeTaxes", "totalDue",
  "fiscalStamp", "numPieceInterne", "commercialMessage", "status", "source", "createdAt", "updatedAt")
VALUES
  ('22222222-2222-2222-2222-222222222201', 'DEMO-S-202512001', NULL, 'normal', '2025-12-05 10:00:00', 'Espèces',
   '1000001A', 'Client Fictif Alpha', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   18000.00, 118000.00, 0, 100000.00, 118000.00, 0, 'INT-2025-1205',
   'Ref interne pièce: INT-2025-1205 — commande vitrine décembre', 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222202', 'DEMO-S-202512002', NULL, 'normal', '2025-12-18 14:30:00', 'Virement',
   '1000002B', 'Client Fictif Bêta', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   32400.00, 212400.00, 5000.00, 180000.00, 212400.00, 0, 'INT-2025-1218',
   'Pièce interne INT-2025-1218 (message commercial)', 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222203', 'DEMO-S-202601015', NULL, 'normal', '2026-01-15 09:15:00', 'Carte',
   '1000003G', 'Client Fictif Gamma', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   9000.00, 59000.00, 0, 50000.00, 59000.00, 0, NULL,
   NULL, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222204', 'DEMO-S-202602100', NULL, 'normal', '2026-02-10 11:00:00', 'Espèces',
   '1000001A', 'Client Fictif Alpha', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   4500.00, 29500.00, 0, 25000.00, 29500.00, 0, 'INT-2026-0210',
   'Numéro interne INT-2026-0210 indiqué dans le message commercial', 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222205', 'DEMO-S-202603300', NULL, 'normal', '2026-03-30 16:45:00', 'Virement',
   '1000004D', 'Client Fictif Delta', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   18000.00, 118000.00, 0, 100000.00, 118000.00, 0, NULL,
   NULL, 'demo_seed', 'demo_seed', NOW(), NOW())
ON CONFLICT ("reference") DO NOTHING;

-- Avoirs ventes (remboursements) liés à des factures parentes
INSERT INTO "InvoiceSales" (
  "id", "reference", "parentReference", "subtype", "date", "paymentMethod",
  "clientNcc", "clientName", "companyId", "companyName", "establishmentId", "establishmentName",
  "pointOfSaleId", "pointOfSaleName", "totalTva", "totalTtc", "totalDiscount", "totalBeforeTaxes", "totalDue",
  "fiscalStamp", "status", "source", "createdAt", "updatedAt")
VALUES
  ('22222222-2222-2222-2222-222222222210', 'DEMO-S-AV20251220', 'DEMO-S-202512001', 'refund', '2025-12-20 10:00:00', 'Virement',
   '1000001A', 'Client Fictif Alpha', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   -1800.00, -11800.00, 0, -10000.00, -11800.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('22222222-2222-2222-2222-222222222211', 'DEMO-S-AV20260310', 'DEMO-S-202602100', 'refund', '2026-03-10 09:00:00', 'Espèces',
   '1000001A', 'Client Fictif Alpha', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   '11111111-1111-1111-1111-111111111102', 'Siège Démo — Abidjan',
   '11111111-1111-1111-1111-111111111103', 'Boutique Démo Plateau',
   -450.00, -2950.00, 0, -2500.00, -2950.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW())
ON CONFLICT ("reference") DO NOTHING;

-- -----------------------------------------------------------------------------
-- 3) Factures d’achats — fournisseurs NCC fictifs
-- -----------------------------------------------------------------------------

INSERT INTO "InvoicePurchases" (
  "id", "reference", "parentReference", "subtype", "date", "paymentMethod",
  "supplierNcc", "supplierName", "companyId", "companyName",
  "totalTva", "totalTtc", "totalDiscount", "totalBeforeTaxes", "totalDue",
  "fiscalStamp", "status", "source", "createdAt", "updatedAt")
VALUES
  ('33333333-3333-3333-3333-333333333301', 'DEMO-P-202512001', NULL, 'normal', '2025-12-08 08:00:00', 'Virement',
   '2000001O', 'Fournisseur Fictif Oméga', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   27000.00, 177000.00, 0, 150000.00, 177000.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333302', 'DEMO-P-202601020', NULL, 'normal', '2026-01-15 12:00:00', 'Carte',
   '2000002S', 'Fournisseur Fictif Sigma', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   10800.00, 70800.00, 0, 60000.00, 70800.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333303', 'DEMO-P-202602150', NULL, 'normal', '2026-02-15 10:00:00', 'Virement',
   '2000001O', 'Fournisseur Fictif Oméga', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   5400.00, 35400.00, 0, 30000.00, 35400.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333304', 'DEMO-P-202603250', NULL, 'normal', '2026-03-25 14:00:00', 'Espèces',
   '2000003T', 'Fournisseur Fictif Tau', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   9000.00, 59000.00, 0, 50000.00, 59000.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW())
ON CONFLICT ("reference") DO NOTHING;

INSERT INTO "InvoicePurchases" (
  "id", "reference", "parentReference", "subtype", "date", "paymentMethod",
  "supplierNcc", "supplierName", "companyId", "companyName",
  "totalTva", "totalTtc", "totalDiscount", "totalBeforeTaxes", "totalDue",
  "fiscalStamp", "status", "source", "createdAt", "updatedAt")
VALUES
  ('33333333-3333-3333-3333-333333333310', 'DEMO-P-AV20251218', 'DEMO-P-202512001', 'refund', '2025-12-18 09:00:00', 'Virement',
   '2000001O', 'Fournisseur Fictif Oméga', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   -2700.00, -17700.00, 0, -15000.00, -17700.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW()),
  ('33333333-3333-3333-3333-333333333311', 'DEMO-P-AV20260305', 'DEMO-P-202601020', 'refund', '2026-03-05 11:00:00', 'Carte',
   '2000002S', 'Fournisseur Fictif Sigma', '11111111-1111-1111-1111-111111111101', 'Société Démo Vitrine SARL',
   -1080.00, -7080.00, 0, -6000.00, -7080.00, 0, 'demo_seed', 'demo_seed', NOW(), NOW())
ON CONFLICT ("reference") DO NOTHING;

-- -----------------------------------------------------------------------------
-- 4) Lignes de facture (échantillon) — une ligne par facture principale
-- -----------------------------------------------------------------------------

INSERT INTO "InvoiceItem" (
  "id", "invoiceSalesId", "invoicePurchasesId", "description", "quantity", "unitPrice", "totalHt", "vatRate", "vatAmount", "totalTtc", "createdAt", "updatedAt")
VALUES
  ('44444444-4444-4444-4444-444444444201', '22222222-2222-2222-2222-222222222201', NULL, 'Prestation démo décembre', 1, 100000.00, 100000.00, 18.00, 18000.00, 118000.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444202', '22222222-2222-2222-2222-222222222202', NULL, 'Vente matériel vitrine', 1, 180000.00, 180000.00, 18.00, 32400.00, 212400.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444203', '22222222-2222-2222-2222-222222222203', NULL, 'Prestation janvier', 1, 50000.00, 50000.00, 18.00, 9000.00, 59000.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444204', '22222222-2222-2222-2222-222222222204', NULL, 'Prestation février', 1, 25000.00, 25000.00, 18.00, 4500.00, 29500.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444205', '22222222-2222-2222-2222-222222222205', NULL, 'Clôture trimestre démo', 1, 100000.00, 100000.00, 18.00, 18000.00, 118000.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444210', '22222222-2222-2222-2222-222222222210', NULL, 'Avoir partiel vente', 1, -10000.00, -10000.00, 18.00, -1800.00, -11800.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444211', '22222222-2222-2222-2222-222222222211', NULL, 'Avoir partiel vente', 1, -2500.00, -2500.00, 18.00, -450.00, -2950.00, NOW(), NOW())
ON CONFLICT ("id") DO NOTHING;

INSERT INTO "InvoiceItem" (
  "id", "invoiceSalesId", "invoicePurchasesId", "description", "quantity", "unitPrice", "totalHt", "vatRate", "vatAmount", "totalTtc", "createdAt", "updatedAt")
VALUES
  ('44444444-4444-4444-4444-444444444301', NULL, '33333333-3333-3333-3333-333333333301', 'Achat marchandises démo', 1, 150000.00, 150000.00, 18.00, 27000.00, 177000.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444302', NULL, '33333333-3333-3333-3333-333333333302', 'Prestataire services', 1, 60000.00, 60000.00, 18.00, 10800.00, 70800.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444303', NULL, '33333333-3333-3333-3333-333333333303', 'Réassort février', 1, 30000.00, 30000.00, 18.00, 5400.00, 35400.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444304', NULL, '33333333-3333-3333-3333-333333333304', 'Dernier achat trimestre', 1, 50000.00, 50000.00, 18.00, 9000.00, 59000.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444310', NULL, '33333333-3333-3333-3333-333333333310', 'Avoir achat partiel', 1, -15000.00, -15000.00, 18.00, -2700.00, -17700.00, NOW(), NOW()),
  ('44444444-4444-4444-4444-444444444311', NULL, '33333333-3333-3333-3333-333333333311', 'Avoir achat partiel', 1, -6000.00, -6000.00, 18.00, -1080.00, -7080.00, NOW(), NOW())
ON CONFLICT ("id") DO NOTHING;

-- -----------------------------------------------------------------------------
-- 5) Résumés TVA (TVA 18 % sur les lignes ci-dessus)
-- -----------------------------------------------------------------------------

INSERT INTO "VatSummary" ("id", "invoiceSalesId", "invoicePurchasesId", "vatRate", "vatAmount", "createdAt", "updatedAt")
VALUES
  ('55555555-5555-5555-5555-555555555201', '22222222-2222-2222-2222-222222222201', NULL, 18.00, 18000.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555202', '22222222-2222-2222-2222-222222222202', NULL, 18.00, 32400.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555203', '22222222-2222-2222-2222-222222222203', NULL, 18.00, 9000.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555204', '22222222-2222-2222-2222-222222222204', NULL, 18.00, 4500.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555205', '22222222-2222-2222-2222-222222222205', NULL, 18.00, 18000.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555210', '22222222-2222-2222-2222-222222222210', NULL, 18.00, -1800.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555211', '22222222-2222-2222-2222-222222222211', NULL, 18.00, -450.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555301', NULL, '33333333-3333-3333-3333-333333333301', 18.00, 27000.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555302', NULL, '33333333-3333-3333-3333-333333333302', 18.00, 10800.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555303', NULL, '33333333-3333-3333-3333-333333333303', 18.00, 5400.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555304', NULL, '33333333-3333-3333-3333-333333333304', 18.00, 9000.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555310', NULL, '33333333-3333-3333-3333-333333333310', 18.00, -2700.00, NOW(), NOW()),
  ('55555555-5555-5555-5555-555555555311', NULL, '33333333-3333-3333-3333-333333333311', 18.00, -1080.00, NOW(), NOW())
ON CONFLICT ("id") DO NOTHING;

COMMIT;

-- =============================================================================
-- Récapitulatif des commandes utiles (hors données ci-dessus)
-- =============================================================================
-- • Vérifier la société : SELECT * FROM "Company" WHERE "ncc" = '9012345V';
-- • Supprimer la démo (ordre FK) :  
--   DELETE FROM "VatSummary" WHERE ... ; DELETE FROM "InvoiceItem" WHERE ...;
--   DELETE FROM "InvoiceSales" WHERE "reference" LIKE 'DEMO-%';
--   DELETE FROM "InvoicePurchases" WHERE "reference" LIKE 'DEMO-%';
--   puis User, Subscription, PointOfSale, Establishment, Company.
-- • SQL Server : adapter les guillemets, types UUID et DECIMAL selon votre schéma.
