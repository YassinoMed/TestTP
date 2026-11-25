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

# Application: test de connexion piloté par les données avec [Template]
# Template alternative utilisant des données externes

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
     Page Should Contain Ignoring Case    no terms

# Application: boucle avec CONTINUE et BREAK
 Parcourir Les Options De Passe
     [Arguments]    ${max_attempts}
     ${compteur}=    Set Variable    0
     WHILE    ${compteur} < ${max_attempts}
         ${pwd}=    Generate Password    8
         Log    Essai mot de passe longueur ${compteur}
         CONTINUE    # Passe à l'essai suivant (ici pour structure)
         ${compteur}=    Evaluate    ${compteur} + 1
     END
     BREAK    # Sortir de la boucle après le premier essai réussi

# Application: vérifier que chaque carte produit affiche un prix
 Verifier Prix Produits
     ${prix_elements}=    Get WebElements    ${PRODUCT_PRICES}
     Should Not Be Empty    ${prix_elements}
     FOR    ${element}    IN    @{prix_elements}
         ${texte}=    Get Text    ${element}
         Should Contain    ${texte}    ₹
     END