# 📊 **Projet Pilotage Décisionnel : Toys & Models**
![Aperçu du Dashboard Interactif :](Assets/Toys-Models-Full-Sales-Performance-Dashboard.png)
**Mission :** Créer un écosystème décisionnel complet, de la base de données brute au dashboard interactif permettant de piloter la performance globale d’une entreprise de vente de modèles réduits avec des indicateurs fiables et actualisés automatiquement.
________________________________________
## 🚀 **1. Démo Interactive**

👉 [**ACCÉDER AU DASHBOARD INTERACTIF**]( https://app.powerbi.com/view?r=eyJrIjoiMGQ3ZDQ2MTgtMWIzZS00NWE3LTgyNDAtZDQyMzUwNDc5NDYyIiwidCI6IjJlMzgyMzJkLTJhOTUtNGI2YS04MzY3LWYxY2NhYTg5YTg3MSJ9
)  
(Rapport Power BI publié via Power BI Service — Interactif, sécurisé et actualisable quotidiennement) 
________________________________________
## 🎯 **2. Problématique**

L'entreprise fictive **Toys & Models**, spécialisée dans la vente de modèles réduits et maquettes, dispose d'une base de données riche mais inexploitée pour le pilotage quotidien. Le directeur souhaite obtenir une visibilité immédiate et automatisée sur la santé globale de son entreprise.  
**L'enjeu de ce projet :** Comment transformer un volume massif de données transactionnelles en indicateurs clés (KPIs) exploitables pour piloter les ventes, la logistique, les finances et les ressources humaines?
________________________________________
## 👥 **3. L'Équipe DataVizion (Groupe 2)**

Ce projet est le résultat d'une collaboration d’une équipe de 4 analystes dans le cadre du bootcamp Data Analyst de la Wild Code School :  

**•	Carole Pons-Bachmann**  
**•	Kenji**  
**•	Mélanie**  
**•	Thomas**
________________________________________
## 🛠️ **4. Outils utilisés**

Pour répondre à ce besoin, notre équipe a utilisé une stack technique complète et professionnelle :  

•	**Base de données :** MySQL (Base de données relationnelle complexe).  
•	**Langages : SQL** (Requêtes avancées, CTE, Vues) et DAX (Mesures calculées personnalisées).  
•	**Outils BI :** Power BI Desktop & Services (Modélisation et publication).  
•	**Design :** Canva (Conception de la charte graphique et support de présentation).  
•	**Collaboration :** Draw.io (Modélisation collaborative du schéma de données).  
•	**Communication :** Discord (Coordination d'équipe et suivi quotidien).
________________________________________
## ⚙️ **5. Méthodologie & Architecture des données**

Notre équipe a suivi la méthode Agile **(4 Sprints)** sur une durée d'un mois, en suivant une logique de transformation de la donnée :  

**•	Ingénierie des données (SQL) :** Analyse de la base MySQL et création de **Vues SQL complexes** (utilisation de CTE et jointures optimisées) pour automatiser le nettoyage et calculer les KPIs demandés.  
**•	Architecture OLAP :** Transformation du schéma transactionnel initial (OLTP) en un **modèle analytique (OLAP) en schéma en étoile** afin de maximiser les performances de calcul et la fluidité dans Power BI.  
**•	Développement BI :** Importation des vues, modélisation des tables de faits et de dimensions, et création de mesures DAX (ex: Évolution du CA vs N-1, calcul des délais de livraison moyens).  
**•	Visualisation & Design :** Réalisation d'un dashboard interactif avec filtres croisés et segments temporels, soutenu par une présentation sur Canva.
________________________________________
## 📈 **6. Résultats & Visualisations (Insights)**

Le dashboard est structuré en quatre axes stratégiques offrant des analyses précises basées sur nos résultats :  

**1. Ressources Humaines (RH)**  
**•	Performance :** Identification du chiffre d'affaires généré par chaque représentant commercial (Résultat : **Gerard Hernandez** est identifié comme le meilleur commercial du groupe).  
**•	Géographie :** Comparaison de la performance des différents bureaux mondiaux pour optimiser la stratégie locale.  

**2. Ventes (Focus CA)**  
**•	Tendances :** Visualisation de l'évolution du CA et détail par catégories de produits (Chiffre Clé : Un Chiffre d'Affaires total de 8,40 M€).  
**•	Rentabilité :** Analyse de la marge brute pour identifier les segments porteurs (Top Produit : La 1992 Ferrari 360 Spider red, et Flop Produit : La 1957 Ford Thunderbird).  

**3. Finances**  
**•	Fidélisation :** Mise en valeur des habitudes d'achat et identification des clients à haut revenu (Chiffre Clé : Un Panier Moyen de 3 170,73 €).  
**•	Saisonnalité :** Analyse de la croissance trimestrielle pour détecter des opportunités (Santé : Un Taux de Recouvrement de 94,69%).  

**4. Logistique**  
**•	Efficacité :** Mesure de la durée globale de traitement des commandes (Chiffre Clé : Un Délai de Livraison Moyen de 3,95 jours).  
**•	Qualité de service :** Identification précise des retards de livraison pour optimiser la chaîne logistique.
________________________________________
## 📂 **7. Structure du Dépôt**

**•	📁 /SQL_Scripts :** Contient 01_Database_Source_Setup.sql et 02_Advanced_SQL_Queries_KPIs.sql.  
**•	📁 /PowerBI_Report :** Contient Toys_Models_Sales_Insights_Dashboard.pbix.  
**•	📁 /Presentation :** Contient Strategic_Business_Analysis_Report.pdf.  
**•	📁 /Assets :** Captures d'écran du dashboard.
________________________________________
## 🚀 **8. Installation & Exécution**

**Option A : Test de l'interactivité (Rapide)**  

**•	Live Demo :** Pour tester les filtres et l'interactivité sans installer de code, consultez directement la démo via le lien **Power BI Services** en haut de cette page.  

**Option B : Installation locale (Technique)**  

**•	Préparation de la donnée :** Importez le script de la base toys_and_models fichier 01_Database_Source_Setup.sql dans /SQL_Scripts sur votre serveur MySQL.  
**•	Transformation analytique :** Exécutez le script SQL fourni (02_Advanced_SQL_Queries_KPIs.sql) pour générer les Vues analytiques (Tables de Faits et Dimensions ).  
**•	Connexion Power BI :** Ouvrez le fichier .pbix dans Power BI Desktop et mettez à jour la source de données vers votre instance MySQL locale.  
**•	Chargement :** Cliquez sur "Actualiser" pour charger les données des vues SQL dans le modèle de données Power BI.
________________________________________
**Carole Pons Bachmann** Data Analyst & Experte Environnement | [LinkedIn]( https://www.linkedin.com/in/carole-pons-bachmann/) 
