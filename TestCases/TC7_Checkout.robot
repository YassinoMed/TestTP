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

# Application: boucle Repeat Keyword pour réessayer
 Tentative Commande Avec Reessai
     [Tags]    retry
     Aller Au Checkout
     Input Text       ${NAME_FIELD}       Walid Dhouib
     Input Text       ${MOBILE_FIELD}     9876543210
     Input Text       ${CO_EMAIL_FIELD}   walid@example.com
     Click Element    ${RADIO_UPI}
     Click Button     ${PLACE_ORDER_BTN}
     Repeat Keyword    3 times
         Page Should Contain    Order placed successfully

# Application: boucle WHILE pour faire le tour du carrousel
 Faire Le Tour Du Carrousel
     ${tours}=    Set Variable    0
     WHILE    ${tours} < 4    limit=6
         Click Element    ${NEXT_BTN}
         ${tours}=    Evaluate    ${tours} + 1
         ${statut}=    Get Text    ${BANNER_STATUS}
         Log    Après ${tours} clic(s) : ${statut}
     END
     Element Text Should Be    ${BANNER_STATUS}    1 of 4

# Application: test de connexion piloté par les données avec template
# (Les tests sont définis via [Template] dans la section Settings)

# Variante: test de login avec plusieurs jeux de données
 Login Avec Plusieurs Jeux De Donnees
     @{donnees}=    Create List
     ...    qa.tester|Passw0rd!|OK
     ...    qa.tester|mauvais|KO
     ...    inconnu|Passw0rd!|KO
     ...    |Passw0rd!|KO
     FOR    ${ligne}    IN    @{donnees}
         @{champs}=    Split String    ${ligne}    |
         ${user}=      Set Variable    ${champs}[0]
         ${pwd}=       Set Variable    ${champs}[1]
         ${attendu}=   Set Variable    ${champs}[2]
         Login Application    ${user}    ${pwd}
         IF    '${attendu}' == 'OK'
             Wait Until Location Does Not Contain    login.html    timeout=5s
             Execute Javascript    window.localStorage.clear()
         ELSE
             Location Should Contain    login.html
         END
     END