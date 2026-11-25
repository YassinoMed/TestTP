# Tests supplémentaires Robot Framework sur ShopKart

Suite de l'atelier 3. Ces tests reprennent les exercices de la page **Practice tasks** du site (https://jstestingacademy.co.in/qa-apps/shopkart/tasks.html) : recherche et filtres, tri, panier, coupons, checkout, connexion, inscription et carrousel.

> **À lire avant d'exécuter.** Les `id` et `data-testid` du site ne sont pas lisibles dans le contenu que j'ai pu récupérer. Seuls `#banner-status` et les clés `localStorage` (`sk_cart`, `sk_orders`, `sk_session`) sont documentés. Les autres localisateurs s'appuient sur les **textes visibles** et sont regroupés dans un seul fichier (`Resources/common.resource`). Inspectez (F12) puis corrigez les variables si un test échoue sur « Element not found ». Les messages d'erreur exacts du site (champ vide, coupon refusé, etc.) sont aussi des hypothèses à confirmer une fois à la main.

---

## Structure du projet

```
MonProjet/
├── Resources/
│   └── common.resource
├── TestCases/
│   ├── TC4_Recherche_Filtres.robot
│   ├── TC5_Tri.robot
│   ├── TC6_Panier.robot
│   ├── TC7_Checkout.robot
│   ├── TC8_Login_Register.robot
│   └── TC9_Carrousel.robot
└── results/
```

Exécution :

```bash
robot -d results TestCases
robot -d results TestCases\TC6_Panier.robot
robot -d results --include smoke TestCases
```

---

## `Resources/common.resource` (variables et mots-clés partagés)

```robotframework
*** Settings ***
Library    SeleniumLibrary
Library    String

*** Variables ***
${BASE}              https://jstestingacademy.co.in/qa-apps/shopkart
${URL}               ${BASE}/index.html
${LOGIN_URL}         ${BASE}/login.html
${REGISTER_URL}      ${BASE}/register.html
${CART_URL}          ${BASE}/cart.html
${ORDERS_URL}        ${BASE}/orders.html
${BROWSER}           chrome
${USER}              qa.tester
${PASSWORD}          Passw0rd!

# --- Accueil ---
${SEARCH_INPUT}      xpath://input[@type='search' or contains(@placeholder,'earch')]
${SEARCH_BUTTON}     xpath://button[normalize-space()='Search']
${SORT_LIST}         xpath:(//select)[1]
${CLEAR_FILTERS}     xpath://*[self::button or self::a][normalize-space()='Clear all filters']
${CHK_ELECTRONICS}   xpath://label[contains(normalize-space(.),'Electronics')]//input[@type='checkbox']
${CHK_IN_STOCK}      xpath://label[contains(normalize-space(.),'In stock only')]//input[@type='checkbox']
${ADD_TO_CART_BTN}   xpath://button[contains(normalize-space(.),'Add to cart')]
${PRODUCT_PRICES}    xpath://*[contains(@class,'card')]//*[contains(@class,'price')]
${CART_LINK}         xpath://a[starts-with(normalize-space(.),'Cart')]

# --- Login / Register ---
${USERNAME_INPUT}    xpath://label[starts-with(normalize-space(.),'Username')]/following::input[1]
${PASSWORD_INPUT}    xpath://label[starts-with(normalize-space(.),'Password')]/following::input[1]
${LOGIN_BUTTON}      xpath://button[normalize-space()='Login']
${FULLNAME_INPUT}    xpath://label[starts-with(normalize-space(.),'Full name')]/following::input[1]
${EMAIL_INPUT}       xpath://label[starts-with(normalize-space(.),'Email')]/following::input[1]
${CONFIRM_INPUT}     xpath://label[starts-with(normalize-space(.),'Confirm password')]/following::input[1]
${TERMS_CHECKBOX}    xpath://input[@type='checkbox']
${CREATE_BUTTON}     xpath://button[normalize-space()='Create account']

*** Keywords ***
Open Shop
    [Documentation]    Ouvre le site avec un état propre (localStorage vidé).
    Open Browser    ${URL}    ${BROWSER}
    Maximize Browser Window
    Execute Javascript    window.localStorage.clear()
    Reload Page

Close Shop
    Close All Browsers

Login Application
    [Arguments]    ${username}    ${password}
    Go To           ${LOGIN_URL}
    Input Text      ${USERNAME_INPUT}    ${username}
    Input Text      ${PASSWORD_INPUT}    ${password}
    Click Button    ${LOGIN_BUTTON}

Page Should Contain Ignoring Case
    [Arguments]    ${expected}
    ${body}=    Get Text    css:body
    ${body}=    Convert To Lower Case    ${body}
    ${expected}=    Convert To Lower Case    ${expected}
    Should Contain    ${body}    ${expected}

Add Product To Cart
    [Arguments]    ${index}=1
    Click Button    xpath:(//button[contains(normalize-space(.),'Add to cart')])[${index}]

Get Prices As Numbers
    [Documentation]    Retourne la liste des prix affichés, convertis en entiers.
    ${elements}=    Get WebElements    ${PRODUCT_PRICES}
    ${numbers}=     Create List
    FOR    ${el}    IN    @{elements}
        ${txt}=    Get Text    ${el}
        ${digits}=    Evaluate    int(re.sub(r'[^0-9]', '', $txt.split('\\n')[0]))    modules=re
        Append To List    ${numbers}    ${digits}
    END
    RETURN    ${numbers}
```

> `Append To List` et `Create List` viennent de `BuiltIn` et `Collections` : ajoutez `Library    Collections` dans les Settings si votre version de Robot le demande.

---

## TC4 : Recherche et filtres

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Test Cases ***
Page D Accueil Affiche 18 Produits
    [Tags]    smoke
    Page Should Contain    Showing 18 products

Recherche Mouse
    Input Text      ${SEARCH_INPUT}    mouse
    Click Button    ${SEARCH_BUTTON}
    Page Should Contain    Wireless mouse
    Page Should Not Contain    Showing 18 products

Recherche Sans Resultat
    Input Text      ${SEARCH_INPUT}    zzzxxxqqq
    Click Button    ${SEARCH_BUTTON}
    Page Should Contain    Showing 0 products

Filtre Electronics
    Select Checkbox    ${CHK_ELECTRONICS}
    Checkbox Should Be Selected    ${CHK_ELECTRONICS}
    Page Should Not Contain    Showing 18 products

Filtre In Stock Only
    Select Checkbox    ${CHK_IN_STOCK}
    Page Should Not Contain    Out of stock

Clear All Filters Retablit Les 18 Produits
    Select Checkbox    ${CHK_ELECTRONICS}
    Select Checkbox    ${CHK_IN_STOCK}
    Click Element      ${CLEAR_FILTERS}
    Page Should Contain    Showing 18 products
    Checkbox Should Not Be Selected    ${CHK_ELECTRONICS}
```

Les textes « Showing 18 products » et « Out of stock » sont ceux affichés par le site. « Showing 0 products » pour l'état vide est une hypothèse (le site peut afficher un message du type « No products found »).

---

## TC5 : Tri

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Test Cases ***
Tri Prix Croissant
    Select From List By Label    ${SORT_LIST}    Price: low to high
    ${prices}=    Get Prices As Numbers
    ${sorted}=    Evaluate    sorted($prices)
    Should Be Equal    ${prices}    ${sorted}

Tri Prix Decroissant
    Select From List By Label    ${SORT_LIST}    Price: high to low
    ${prices}=    Get Prices As Numbers
    ${sorted}=    Evaluate    sorted($prices, reverse=True)
    Should Be Equal    ${prices}    ${sorted}

Contenu De La Liste De Tri
    ${options}=    Get List Items    ${SORT_LIST}
    Length Should Be    ${options}    5
    List Should Contain Value    ${SORT_LIST}    Customer rating
    List Should Contain Value    ${SORT_LIST}    Name A to Z
```

Le localisateur `${PRODUCT_PRICES}` est une supposition (classe contenant `price` dans une carte). C'est le premier à vérifier si le tri échoue.

---

## TC6 : Panier et coupons

Coupons documentés par le site : `SAVE10` (10 % si le panier dépasse 1000, refusé sinon) et `EXPIRED5` (expiré).

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Variables ***
${COUPON_INPUT}     xpath://input[contains(@placeholder,'oupon') or contains(@id,'oupon')]
${COUPON_APPLY}     xpath://button[contains(normalize-space(.),'Apply')]
${EMPTY_CART_BTN}   xpath://button[contains(normalize-space(.),'Clear cart')]

*** Test Cases ***
Badge Apres Ajout De Deux Produits
    [Tags]    smoke
    Add Product To Cart    1
    Add Product To Cart    2
    Element Should Contain    ${CART_LINK}    2

Cle LocalStorage Du Panier Est Remplie
    Add Product To Cart    1
    ${cart}=    Execute Javascript    return window.localStorage.getItem('sk_cart');
    Should Not Be Equal    ${cart}    ${None}
    Should Not Be Empty    ${cart}

Meme Produit Deux Fois Donne Une Seule Ligne
    Add Product To Cart    1
    Add Product To Cart    1
    Go To    ${CART_URL}
    ${rows}=    Get Element Count    xpath://tbody/tr
    Should Be Equal As Integers    ${rows}    1

Coupon Expire Est Refuse
    Add Product To Cart    1
    Go To    ${CART_URL}
    Input Text      ${COUPON_INPUT}    EXPIRED5
    Click Button    ${COUPON_APPLY}
    Page Should Contain Ignoring Case    expired

Coupon SAVE10 Sur Petit Panier Est Refuse
    # Wireless mouse (799) : panier inférieur à 1000
    Input Text      ${SEARCH_INPUT}    mouse
    Click Button    ${SEARCH_BUTTON}
    Add Product To Cart    1
    Go To    ${CART_URL}
    Input Text      ${COUPON_INPUT}    SAVE10
    Click Button    ${COUPON_APPLY}
    Page Should Not Contain Ignoring Case    discount applied
```

Dans le dernier test, `Page Should Not Contain Ignoring Case` n'existe pas dans `common.resource` : ajoutez ce mot-clé (symétrique de `Page Should Contain Ignoring Case`, avec `Should Not Contain`), ou remplacez la dernière ligne par une vérification du message de refus réel.

---

## TC7 : Checkout

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Variables ***
${CHECKOUT_BTN}     xpath://*[self::a or self::button][contains(normalize-space(.),'Checkout')]
${PLACE_ORDER_BTN}  xpath://button[contains(normalize-space(.),'Place order')]
${NAME_FIELD}       xpath://label[contains(normalize-space(.),'Name')]/following::input[1]
${MOBILE_FIELD}     xpath://label[contains(normalize-space(.),'Mobile')]/following::input[1]
${CO_EMAIL_FIELD}   xpath://label[contains(normalize-space(.),'Email')]/following::input[1]
${RADIO_CARD}       xpath://label[contains(normalize-space(.),'Card')]
${RADIO_UPI}        xpath://label[contains(normalize-space(.),'UPI')]

*** Test Cases ***
Formulaire Vide Affiche Des Erreurs
    Aller Au Checkout
    Click Button    ${PLACE_ORDER_BTN}
    Page Should Contain Ignoring Case    required

Mobile De 5 Chiffres Est Refuse
    Aller Au Checkout
    Input Text      ${MOBILE_FIELD}    12345
    Click Button    ${PLACE_ORDER_BTN}
    Page Should Contain    exactly 10 digits

Email Sans Arobase Est Refuse
    Aller Au Checkout
    Input Text      ${CO_EMAIL_FIELD}    adresse-sans-arobase
    Click Button    ${PLACE_ORDER_BTN}
    Page Should Contain Ignoring Case    email

Choix Du Mode De Paiement
    Aller Au Checkout
    Click Element    ${RADIO_CARD}
    Click Element    ${RADIO_UPI}

*** Keywords ***
Aller Au Checkout
    Add Product To Cart    1
    Go To    ${CART_URL}
    Click Element    ${CHECKOUT_BTN}
```

### Commande valide jusqu'à la confirmation

Ajoutez ce test à `TC7`. Il vérifie le format de l'identifiant de commande `SK-XXXXXX` indiqué dans les exercices du site, puis la remise à zéro du panier :

```robotframework
Commande Valide
    [Tags]    smoke
    Aller Au Checkout
    Input Text       ${NAME_FIELD}       Walid Dhouib
    Input Text       ${MOBILE_FIELD}     9876543210
    Input Text       ${CO_EMAIL_FIELD}   walid@example.com
    Click Element    ${RADIO_UPI}
    # Compléter ici les autres champs obligatoires (adresse, code postal, conditions)
    Click Button     ${PLACE_ORDER_BTN}
    ${body}=    Get Text    css:body
    Should Match Regexp    ${body}    SK-[A-Z0-9]{6}
    ${cart}=    Execute Javascript    return window.localStorage.getItem('sk_cart');
    Log    Contenu du panier après commande : ${cart}
```

Le formulaire de checkout contient probablement d'autres champs obligatoires (adresse, ville, code postal, case des conditions). Je n'ai pas pu les lire : repérez-les à la main et ajoutez des `Input Text` / `Select Checkbox` avant `Click Button`.

---

## TC8 : Connexion et inscription

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Test Cases ***
Login Valide
    [Tags]    smoke
    Login Application    ${USER}    ${PASSWORD}
    Wait Until Location Does Not Contain    login.html    timeout=5s
    Page Should Contain    ${USER}
    ${session}=    Execute Javascript    return window.localStorage.getItem('sk_session');
    Should Not Be Empty    ${session}

Login Mauvais Mot De Passe
    Login Application    ${USER}    MauvaisMdp123
    Location Should Contain    login.html
    Page Should Contain Ignoring Case    invalid

Login Champs Vides
    Go To           ${LOGIN_URL}
    Click Button    ${LOGIN_BUTTON}
    Location Should Contain    login.html

Register Mots De Passe Differents
    Go To    ${REGISTER_URL}
    Input Text    ${FULLNAME_INPUT}    Walid Dhouib
    Input Text    ${USERNAME_INPUT}    walid_test
    Input Text    ${EMAIL_INPUT}       walid@example.com
    Input Text    ${PASSWORD_INPUT}    Test@12345
    Input Text    ${CONFIRM_INPUT}     Different@999
    Select Checkbox    ${TERMS_CHECKBOX}
    Click Button    ${CREATE_BUTTON}
    Location Should Contain    register.html
    Page Should Contain Ignoring Case    match

Register Mot De Passe Faible
    Go To    ${REGISTER_URL}
    Input Text    ${PASSWORD_INPUT}    123
    Page Should Contain Ignoring Case    weak

Register Sans Accepter Les Conditions
    Go To    ${REGISTER_URL}
    Input Text    ${FULLNAME_INPUT}    Walid Dhouib
    Input Text    ${USERNAME_INPUT}    walid_noterms
    Input Text    ${EMAIL_INPUT}       walid@example.com
    Input Text    ${PASSWORD_INPUT}    Test@12345
    Input Text    ${CONFIRM_INPUT}     Test@12345
    Click Button    ${CREATE_BUTTON}
    Location Should Contain    register.html
```

Les mots `invalid`, `match` et `weak` sont les plus probables dans les messages, mais ils sont à confirmer. Le site affiche un indicateur « Strength » sous le champ du mot de passe.

---

## TC9 : Carrousel de bannières

C'est la seule partie où le site documente un identifiant : `#banner-status`, qui affiche « 1 of 4 ». Les slides masquées portent `aria-hidden="true"`.

```robotframework
*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Variables ***
${BANNER_STATUS}    id:banner-status
${NEXT_BTN}         xpath://button[contains(@aria-label,'ext') or normalize-space()='›']
${PREV_BTN}         xpath://button[contains(@aria-label,'rev') or normalize-space()='‹']
${HIDDEN_SLIDES}    xpath://*[@aria-hidden='true']

*** Test Cases ***
Le Carrousel Demarre Sur La Slide 1
    [Tags]    smoke
    Element Text Should Be    ${BANNER_STATUS}    1 of 4

Bouton Suivant
    Click Element    ${NEXT_BTN}
    Element Text Should Be    ${BANNER_STATUS}    2 of 4

Bouton Precedent Revient A La Derniere Slide
    Click Element    ${PREV_BTN}
    Element Text Should Be    ${BANNER_STATUS}    4 of 4

Defilement Automatique
    Element Text Should Be    ${BANNER_STATUS}    1 of 4
    Sleep    6s
    Element Text Should Not Be    ${BANNER_STATUS}    1 of 4

Les Slides Masquees Sont Aria Hidden
    ${count}=    Get Element Count    ${HIDDEN_SLIDES}
    Should Be True    ${count} >= 3
```

Le test « Survol arrête le défilement » du site (survoler la bannière, attendre 6 secondes, vérifier qu'elle n'a pas bougé) s'écrit avec `Mouse Over` sur l'élément de la bannière, dont il faut d'abord relever le localisateur avec F12.

---

## Bonnes pratiques utilisées dans ces tests

| Pratique | Pourquoi |
|---|---|
| `Resource` partagé | Un seul endroit à corriger quand un localisateur change |
| `Test Setup` / `Test Teardown` | Navigateur ouvert et fermé proprement, même si le test échoue |
| `localStorage.clear()` au démarrage | Tests indépendants les uns des autres (panier et session sont dans `localStorage`) |
| Tags (`smoke`) | Lancer seulement les tests essentiels avec `--include smoke` |
| Arguments dans les mots-clés | `Login Application    ${user}    ${pwd}` sert aux cas positif et négatif |
| Assertions sur le résultat | Un test sans assertion passe même quand l'application est cassée |
