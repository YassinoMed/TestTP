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

# Application: tester toutes les options de tri avec une boucle FOR IN
 Toutes Les Options De Tri
     [Tags]    sort
     FOR    ${option}    IN    @{SORT_OPTIONS}
         Select From List By Label    ${SORT_LIST}    ${option}
         ${prices}=    Get Prices As Numbers
         Log    Option testée : ${option}
     END

# Application: tri par index (index commence à 0)
 Tri Par Index
     FOR    ${i}    IN RANGE    0    5
         Select From List By Index    ${SORT_LIST}    ${i}
         ${label}=    Get Selected List Label    ${SORT_LIST}
         Log    Index ${i} correspond à : ${label}
     END

# Application: parcourir les catégories avec FOR IN
 Categories Avec Tri
     FOR    ${cat}    IN    @{CATEGORIES}
         ${locator}=    Set Variable    xpath://label[contains(normalize-space(.),'${cat}')]//input[@type='checkbox']
         Select Checkbox    ${locator}
         FOR    ${option}    IN    @{SORT_OPTIONS}
             Select From List By Label    ${SORT_LIST}    ${option}
             Log    ${cat} + ${option}
         END
         Unselect Checkbox    ${locator}
     END