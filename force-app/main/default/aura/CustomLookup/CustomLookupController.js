/*
 * @Descripttion: 
 * @Author: Devin
 * @Date: 2021-10-19 17:38:25
 * @LastEditors: Devin
 * @LastEditTime: 2021-10-19 20:17:45
 */
({
    doInit : function( component, event, helper ) {
        $A.util.toggleClass(component.find('resultsDiv'),'slds-is-open');
        if( !$A.util.isEmpty(component.get('v.value')) ) {
            helper.searchRecordsHelper( component, event, helper, component.get('v.value') );
        }

    },
    
    // When a keyword is entered in search box
    searchRecords : function( component, event, helper ) {
        if( !$A.util.isEmpty(component.get('v.searchString')) ) {
            helper.searchRecordsHelper( component, event, helper, '' );
            } else {
               $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // When an item is selected
    selectItem : function( component, event, helper ) {
        if(!$A.util.isEmpty(event.currentTarget.id)) {
            var recordsList = component.get('v.recordsList');
            var index = recordsList.findIndex(x => x.value === event.currentTarget.id)
            if(index != -1) {
                var selectedRecord = recordsList[index];
            }
            component.set('v.selectedRecord',selectedRecord);
            component.set('v.value',selectedRecord.value);
            $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');

            //传值到父级 设置Event 组件
            var compEvent = component.getEvent("sampleComponentEvent");
            compEvent.setParams({"selectedRecord" : selectedRecord.value });
            compEvent.fire();

            console.log('selectedRecord----'+selectedRecord);
        }
    },
       
    showRecords : function( component, event, helper ) {
        if(!$A.util.isEmpty(component.get('v.recordsList')) && !$A.util.isEmpty(component.get('v.searchString'))) {
            $A.util.addClass(component.find('resultsDiv'),'slds-is-open');
        }
    },
    
    // To remove the selected item.
    removeItem : function( component, event, helper ){

        // 清除数据
        var compEvent = component.getEvent("sampleComponentEvent");
        compEvent.setParams({"selectedRecord" : '' });
        compEvent.fire();

        component.set('v.selectedRecord','');
        component.set('v.value','');
        component.set('v.searchString','');
        setTimeout( function() {
            component.find( 'inputLookup' ).focus();
        }, 250);
    },
    
    // To close the dropdown if clicked outside the dropdown.
    blurEvent : function( component, event, helper ){
        $A.util.removeClass(component.find('resultsDiv'),'slds-is-open');
    },
})