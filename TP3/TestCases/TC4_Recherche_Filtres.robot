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
     Checkbox Should Not Be Selected    ${CHK_IN_STOCK}