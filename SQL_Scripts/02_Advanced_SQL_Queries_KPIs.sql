/* =============================================================================
PROJET : TOYS & MODELS - ANALYSE DÉCISIONNELLE
ÉQUIPE : DATA VIZION (GROUPE 2)
OBJECTIF : Extraction des KPIs et création de la structure OLAP (Vues)
=============================================================================
*/

use toys_and_models ;

-- ==========================================================================
-- 1. PARTIE RESSOURCES HUMAINES (RH)
-- Objectif : Analyser la performance commerciale des employés et des bureaux
-- ==========================================================================

-- RH01 : Performance individuelle - Chiffre d'affaires (CA) par représentant
-- Ce KPI permet d'identifier les meilleurs vendeurs en cumulant les ventes validées.
SELECT e.employeeNumber,
        e.lastName,
        e.firstName,
        SUM(od.quantityOrdered * od.priceEach) AS total_sold_per_employee
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN employees e ON e.employeeNumber = c.salesRepEmployeeNumber
WHERE o.status NOT IN ('cancelled','On Hold')
GROUP BY e.employeeNumber, e.lastName, e.firstName
ORDER BY total_sold_per_employee DESC;


-- RH02 : Suivi financier par représentant - Écart Commandes vs Paiements
-- Analyse de la capacité de recouvrement : compare ce qui a été vendu et ce qui a été réellement encaissé.
SELECT 
	e1.employeeNumber, 
    e1.lastName, 
    e1.firstName, 
    e1.jobTitle,
    commandes_passees, 
    paiements_recus, 
    (commandes_passees - paiements_recus) AS difference
FROM 
	employees e1 
    LEFT JOIN
		(SELECT e.employeeNumber, IFNULL(SUM(od.quantityOrdered * od.priceEach),0) AS commandes_passees
		FROM employees e 
			LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
			LEFT JOIN orders o ON c.customerNumber = o.customerNumber
			LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
		GROUP BY e.employeeNumber) T1 
	ON e1.employeeNumber = T1.employeeNumber
	LEFT JOIN
		(SELECT e.employeeNumber, IFNULL(SUM(p.amount),0) AS paiements_recus
		FROM employees e 
			LEFT JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber
			LEFT JOIN payments p ON c.customerNumber = p.customerNumber
		GROUP BY e.employeeNumber) T2 
	ON e1.employeeNumber = T2.employeeNumber
WHERE e1.jobTitle LIKE 'Sales Rep'
ORDER BY e1.lastName, e1.firstName;


-- RH03 : Performance géographique - CA généré par bureau et par année
-- Permet de visualiser la croissance ou le déclin des revenus par implantation physique.
select offi.officeCode, year(orderDate), SUM(od.quantityOrdered*od.priceEach)
from offices offi 
join employees e on e.officeCode = offi.officeCode 
join customers c on c.salesRepEmployeeNumber = e.employeeNumber 
join orders o on o.customerNumber = c.customerNumber 
join orderdetails od on od.orderNumber = o.orderNumber
group by year(orderDate), offi.officeCode Order by offi.officeCode, year(orderDate);


-- ==========================================================================
-- 2. PARTIE VENTES (VT)
-- Objectif : Analyser les tendances de revenus, les produits et la fidélité
-- ==========================================================================

-- VT01 : Évolution temporelle et régionale des revenus
-- Suivi mensuel du CA par territoire pour identifier les saisonnalités géographiques.
select year(o.orderDate), month(o.orderDate), offices.territory,  SUM(od.quantityOrdered*od.priceEach) as "revenus" 
from offices 
join employees e on offices.officeCode = e.officeCode 
join customers c on c.salesRepEmployeeNumber = e.employeeNumber 
join orders o on o.customerNumber = c.customerNumber 
join orderdetails od on o.orderNumber = od.orderNumber
group by year(o.orderDate), month(o.orderDate), offices.territory 
order by offices.territory, year(o.orderDate), month(o.orderDate);


-- VT02 : Top et Flop Produits par catégorie
-- Utilisation de fonctions de fenêtrage (RANK) pour isoler les extrêmes de performance catalogue.
-- Les 3 produits les plus vendus pour chaque categorie
WITH cte_products AS(
SELECT 
	p.productLine, 
    p.productCode, 
    p.productName, 
    SUM(od.quantityOrdered) AS quantite_vendue, 
    RANK() OVER(PARTITION BY p.productLine ORDER BY SUM(od.quantityOrdered) DESC) AS ranking 
FROM products p 
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName
)
SELECT productLine, productCode, productName, quantite_vendue, ranking
FROM cte_products
WHERE ranking <= 3
;
-- Les 3 produits les moins vendus pour chaque categorie
WITH cte_products AS(
SELECT productLine, productCode, productName, quantite_vendue, ranking,
MAX(ranking) OVER(PARTITION BY productLine) AS max_ranking
FROM 
(SELECT 
	p.productLine, 
    p.productCode, 
    p.productName, 
    SUM(od.quantityOrdered) AS quantite_vendue, 
    RANK() OVER(PARTITION BY p.productLine ORDER BY SUM(od.quantityOrdered) DESC) AS ranking
FROM products p 
JOIN orderdetails od ON p.productCode = od.productCode
GROUP BY p.productCode, p.productName) T1
)
SELECT productLine, productCode, productName, quantite_vendue, ranking, max_ranking
FROM cte_products
WHERE ranking > (max_ranking -3)
ORDER BY productLine, ranking DESC;


-- VT03 : Analyse de la rentabilité (Marges)
-- Calcul de la marge théorique et réelle pour orienter la stratégie commerciale.
# Pour trouver les 5 produits ayant la meilleure marge pour une catégorie :
SELECT productCode, productName, productLine, buyPrice, MSRP,
        MSRP-buyPrice AS margin_per_product
FROM products
WHERE productLine LIKE 'Classic Cars'       # changer la catégorie
ORDER BY margin_per_product DESC          # ASC pour les marges les plus basses
LIMIT 5;

# Analyse de la marge totale générée par ligne de produit (Product Line) :
SELECT
    p.productLine,
    SUM(od.quantityOrdered) AS total_quantity_ordered,
    SUM((p.MSRP - p.buyPrice) * od.quantityOrdered) AS total_margin_per_product_line
FROM orderdetails od
JOIN products p ON od.productCode = p.productCode
GROUP BY p.productLine
ORDER BY total_margin_per_product_line DESC;


-- VT04 : Volume de ventes historique par catégorie
-- Permet d'analyser la popularité des gammes de produits dans le temps.
SELECT pl.productLine, MONTH(o.orderDate) AS mois, YEAR(o.orderDate) AS annee, SUM(od.quantityOrdered) AS nb_ventes
FROM  productlines pl
	LEFT JOIN products p ON pl.productLine = p.productLine
    LEFT JOIN orderdetails od ON p.productCode = od.productCode
    JOIN orders o ON o.orderNumber = od.orderNumber
GROUP BY productLine, mois, annee
ORDER BY productLine, annee, mois;


-- VT05 : Panier Moyen par bureau
-- Calcule la valeur moyenne d'une commande par point de vente (City/Office).
WITH prix_par_commande AS (
        SELECT A.orderNumber, A.customerNumber, sum(B.quantityOrdered * B.priceEach) as total_commande
        FROM orders A
        JOIN orderdetails B ON A.orderNumber = B.orderNumber
        GROUP BY A.orderNumber
)
SELECT D.officeCode, D.city, ROUND(AVG(A.total_commande),2) as moyenne_des_commandes
FROM prix_par_commande A
JOIN customers B ON A.customerNumber = B.customerNumber
LEFT JOIN employees C ON B.salesRepEmployeeNumber = C.employeeNumber
LEFT JOIN offices D ON C.officeCode = D.officeCode
GROUP BY D.officeCode;


-- VT06 : Fidélité Client - Top 5 clients récurrents
-- Identifie les clients stratégiques selon le nombre de commandes passées.
SELECT c.customerName, c.customerNumber, COUNT(o.orderNumber) AS number_of_orders_per_customer
FROM customers c
JOIN orders o ON o.customerNumber = c.customerNumber
GROUP BY c.customerName, c.customerNumber
ORDER BY number_of_orders_per_customer DESC
LIMIT 5;


-- ==========================================================================
-- 3. PARTIE FINANCES (FN)
-- Objectif : Analyser la santé financière et les flux de trésorerie
-- ==========================================================================

-- FN01 : Top 5 clients par CA
-- Classement des clients apportant la plus grande valeur financière.
SELECT c.customerName,
                o.customerNumber,
        SUM(od.quantityOrdered * od.priceEach) AS total_price_per_customer
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN orderdetails od ON o.orderNumber = od.orderNumber
WHERE o.status NOT IN ('cancelled','On Hold')
GROUP BY o.customerNumber
ORDER BY total_price_per_customer DESC
LIMIT 5;


-- FN02 : Taux de recouvrement des créances
-- Calcule le pourcentage des montants commandés qui a été effectivement payé par client.
Select c.customerNumber, c.customerName, (sum(ord.`prix commande`)/sum(p.amount))*100 as `Taux recouvrement créance` 
from customers c 
left join (select o.orderNumber, o.customerNumber, SUM(od.quantityOrdered*od.priceEach) as `prix commande` from orders o left join orderdetails od on o.orderNumber = od.orderNumber group by o.orderNumber) ord on c.customerNumber = ord.customerNumber 
left join payments p on c.customerNumber = p.customerNumber 
group by c.customerNumber 
order by `Taux recouvrement créance`;


-- FN03 : Croissance trimestrielle des ventes
-- Analyse de la dynamique de croissance au format Quarterly pour les rapports financiers.
SELECT
        EXTRACT(QUARTER FROM o.orderDate) AS trimestre,
    EXTRACT(YEAR FROM o.orderDate) AS yr,
    COUNT(DISTINCT o.orderNumber) AS nb_sales,
    SUM(od.quantityOrdered*od.priceEach) AS sales_amount
FROM
        orders o
LEFT JOIN
        orderdetails od
                ON
                        o.orderNumber=od.orderNumber
where
        o.status not like 'Cancelled' and o.status not like 'On Hold'
GROUP BY
EXTRACT(YEAR FROM o.orderDate), EXTRACT(QUARTER FROM o.orderDate)
ORDER BY
EXTRACT(YEAR FROM o.orderDate) DESC, EXTRACT(QUARTER FROM o.orderDate) DESC;


-- FN04 : Analyse des paiements clients vs Moyenne Globale
-- Identifie les clients "petits payeurs" dont la moyenne est inférieure à la moyenne de l'entreprise.
select (sum(p.amount)/count(p.checkNumber)) as "moyenne_paiements" from payments p;

select c.customerName, mpc.moy_paiements_client
from customers c 
join (select c.customerName, (sum(p.amount)/count(p.checkNumber)) as moy_paiements_client from customers c join payments p on c.customerNumber = p.customerNumber group by c.customerName) mpc 
on c.customerName = mpc.customerName 
join payments on payments.customerNumber = c.customerNumber 
group by customerName 
Having mpc.moy_paiements_client < (select (sum(payments.amount)/count(payments.checkNumber)) from payments) 
order by mpc.moy_paiements_client;


-- ==========================================================================
-- 4. PARTIE LOGISTIQUE (LG)
-- Objectif : Optimiser les stocks et les délais de livraison
-- ==========================================================================

-- LG01 : Alerte Stock Critique
-- Identifie les produits dont le stock est inférieur à 100 unités pour prévenir les ruptures.
SELECT
        productName,
    quantityInStock
FROM
        products
WHERE
        quantityInStock<100
ORDER BY quantityInStock ASC;

-- Temps de préparation moyen par commande (Expédiée - Commandée)
SELECT
        orderNumber,
    orderDate,
    shippedDate,
    DATEDIFF(shippedDate,orderDate) AS time_to_prepare_order
FROM
        orders
WHERE
        shippedDate IS NOT NULL;


-- LG02 : Analyse de l'Efficacité Opérationnelle
-- Création d'une vue pour centraliser les données de livraison.
CREATE VIEW deliver AS(
SELECT
        o.orderNumber,
    o.orderDate,
    o.requiredDate,
    o.shippedDate,
    DATEDIFF(shippedDate,orderDate) AS delivery_time,
    o.status,
    o.comments,
    c.*
FROM
        orders AS o
INNER JOIN
        customers AS c
                ON o.customerNumber=c.customerNumber
WHERE
        shippedDate IS NOT NULL);

-- Moyenne globale du temps de livraison
SELECT
    ROUND(AVG(delivery_time),2) AS mean_time
FROM
        deliver;
    
-- Identification des commandes dépassant le temps de livraison moyen
SELECT
        orderNumber,
    customerName,
    addressLine1,
    addressLine2,
    City,
    country,
    delivery_time
FROM
        deliver
WHERE
        delivery_time>(
                                        SELECT
                    ROUND(AVG(delivery_time),2) AS mean_time
                                        FROM
                    deliver);


-- LG03 : Taux de rotation des stocks
-- Analyse par mois des ventes par produit pour mesurer l'écoulement du stock.
SELECT
        p.productCode,
    p.productName,
    p.productLine,
    p.productVendor,
    p.quantityInStock,
    p.buyPrice,
    SUM(od.quantityOrdered) AS number_of_sales,
    SUBSTR(o.orderDate,1,7) AS sale_date
FROM
        products p
LEFT JOIN
        orderdetails od
                ON
                        p.productCode=od.productCode
LEFT JOIN
        orders o
                ON
                        o.orderNumber=od.orderNumber
where
        o.shippedDate IS NOT NULL and o.status not like 'Cancelled'
GROUP BY
        p.productCode, sale_date 
ORDER BY
        p.productCode,
    sale_date;


-- LG04 : Suivi des anomalies (Retards de livraison)
-- Calcul de la fiabilité logistique : comparaison entre Date Réelle et Date Requise.
SELECT SUM(shippedDate > requiredDate) AS total_delayed_orders,
    SUM(shippedDate <= requiredDate) AS total_early_or_on_time_orders
FROM orders; 

-- Focus sur la commande en retard pour identification des causes
SELECT o.orderNumber, o.requiredDate, o.shippedDate, c.customerName,
        e.lastName AS employee_lastName,
    e.firstName AS employee_firstName,
    e.officeCode, oc.city AS office_city
FROM orders o
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
JOIN offices oc ON e.officeCode = oc.officeCode
WHERE o.shippedDate > o.requiredDate;


-- ==========================================================================
-- 5. ARCHITECTURE OLAP (VUES POUR POWER BI)
-- Objectif : Préparer les tables de Faits et de Dimensions pour le Dashboard
-- ==========================================================================

-- Vue Dimension : Produits
CREATE VIEW DIM_PRODUCT AS (
SELECT
productCode,
productName,
productLine,
MSRP,
quantityInStock
FROM
products);

-- Vue Dimension : Clients
CREATE VIEW DIM_CUSTOMER AS (
                              SELECT customerNumber, customerName, city, state, country, creditLimit
                              FROM customers
);

-- Vue Table de Faits : Ventes (Fact_Order)
-- Regroupe les métriques transactionnelles principales pour l'analyse Power BI.
CREATE VIEW fact_order AS 
	SELECT 
		o.orderNumber, 
		o.orderDate, 
		o.requiredDate, 
		o.shippedDate, 
		o.customerNumber, 
		od.productCode,
		c.salesRepEmployeeNumber,
		od.quantityOrdered,
		od.priceEach,
		(p.MSRP - p.buyPrice) AS product_margin,
		(od.quantityOrdered * od.priceEach) AS total_price_product
	FROM orders o
	LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
	LEFT JOIN customers c ON o.customerNumber = c.customerNumber
	JOIN products p ON od.productCode = p.productCode;

-- Vue Table de Faits : Paiements
CREATE view FACT_PAYMENT as
select p.customerNumber, p.checkNumber, p.PaymentDate, p.Amount
from payments p;

-- Vue Dimension : Bureaux et Employés
create view DIM_OFFICE as
select e.employeeNumber, e.lastName, e.firstName, o.officeCode, e.jobTitle, o.city, o.state, o.country, o.territory
from employees e join offices o on e.officeCode = o.officeCode
Order by e.employeeNumber;

-- Vue Dimension : Calendrier (Date Table)
-- Génération d'une série temporelle récursive pour les analyses Time Intelligence.
SET @@cte_max_recursion_depth = 3000;
CREATE TABLE DIM_DATES (
WITH RECURSIVE date_series AS (
    SELECT DATE('2019-01-01') AS full_date
    UNION ALL
    SELECT DATE_ADD(full_date, INTERVAL 1 DAY)
    FROM date_series
    WHERE full_date < DATE('2025-12-31')
)
SELECT
    full_date AS order_date,
    YEAR(full_date) AS year,
    MONTH(full_date) AS month,
    QUARTER(full_date) AS quarter,
    DATE_FORMAT(full_date, '%M') AS month_name,
    WEEK(full_date, 1) AS week_number,
    DAY(full_date) AS day_of_month,
    DAYNAME(full_date) AS day_name
FROM date_series);

-- Vue Dimension : Statuts des Commandes
create view DIM_ORDERS as select orderNumber, status from orders;

-- Mise à jour de la table de faits pour inclure la marge brute réelle et prix moyen
CREATE OR REPLACE VIEW fact_order AS 
    SELECT 
        o.orderNumber, 
        o.orderDate, 
        o.requiredDate, 
        o.shippedDate, 
        o.customerNumber, 
        od.productCode,
        c.salesRepEmployeeNumber,
        od.quantityOrdered,
        od.priceEach,
        p.buyPrice,
        (od.quantityOrdered * od.priceEach) AS total_price_product,
        AVG(od.priceEach) OVER(PARTITION BY od.productCode) AS moyenne_priceEach
    FROM orders o
    LEFT JOIN orderdetails od ON o.orderNumber = od.orderNumber
    LEFT JOIN customers c ON o.customerNumber = c.customerNumber
    JOIN products p ON od.productCode = p.productCode;