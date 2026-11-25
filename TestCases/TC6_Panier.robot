*** Settings ***
Resource         ../Resources/common.resource
Test Setup       Open Shop
Test Teardown    Close Shop

*** Variables ***
${COUPON_INPUT}     xpath://input[contains(@placeholder,'oupon') or contains(@id,'oupon')]
${COUPON_APPLY}     xpath://button[contains(normalize-space(.),'Apply')]

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

# Application: tester plusieurs coupons avec FOR IN ZIP
 Coupons Divers
     [Tags]    coupon
     Add Product To Cart    1
     Go To    ${CART_URL}
     FOR    ${coupon}    ${attendu}    IN ZIP    ${COUPONS}    ${COUPON_RESULTS}
         Input Text      ${COUPON_INPUT}    ${coupon}
         Click Button    ${COUPON_APPLY}
         Page Should Contain Ignoring Case    ${attendu}
         Log    Coupon ${coupon} : message attendu '${attendu}'
     END

# Application: ajouter N produits au panier avec une boucle
 Ajouter Trois Produits Au Panier
     [Arguments]    ${nombre}=3
     FOR    ${i}    IN RANGE    1    ${nombre} + 1
         Add Product To Cart    ${i}
     END
     Element Should Contain    ${CART_LINK}    ${nombre}

# Application: vérifier que chaque prix contient le symbole roupie
 Chaque Prix Contient Le Symbole Roupie
     ${prix}=    Get WebElements    ${PRODUCT_PRICES}
     Should Not Be Empty    ${prix}
     FOR    ${element}    IN    @{prix}
         ${texte}=    Get Text    ${element}
         Should Contain    ${texte}    ₹
     END