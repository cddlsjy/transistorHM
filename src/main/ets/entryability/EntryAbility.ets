/**
 * EntryAbility.ets
 * Main entry point for Transistor Radio App on HarmonyOS
 * 
 * Transformed from Android to HarmonyOS
 * Original: org.y20k.transistor.MainActivity
 */

import UIAbility from '@ohos.app.ability.UIAbility';
import Window from '@ohos.window';
import hilog from '@ohos.hilog';
import PreferencesHelper from '../helpers/PreferencesHelper';
import FileHelper from '../helpers/FileHelper';

const TAG = 'EntryAbility';
const DOMAIN = 0x0001;

export default class EntryAbility extends UIAbility {
  onCreate(want, launchParam) {
    hilog.info(DOMAIN, TAG, 'EntryAbility onCreate');
    
    // Initialize preferences
    PreferencesHelper.init(this.context);
    
    // Create .nomedia file if not exists
    FileHelper.createNomediaFile(this.context);
  }

  onDestroy() {
    hilog.info(DOMAIN, TAG, 'EntryAbility onDestroy');
  }

  onWindowStageCreate(windowStage: Window.WindowStage) {
    // Load main page
    hilog.info(DOMAIN, TAG, 'EntryAbility onWindowStageCreate');
    
    // Set up main window
    windowStage.loadContent('pages/Index', (err, data) => {
      if (err.code) {
        hilog.error(DOMAIN, TAG, 'Failed to load content: ' + JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, TAG, 'Succeeded in loading content.');
    });
  }

  onWindowStageDestroy() {
    hilog.info(DOMAIN, TAG, 'EntryAbility onWindowStageDestroy');
  }

  onForeground() {
    hilog.info(DOMAIN, TAG, 'EntryAbility onForeground');
  }

  onBackground() {
    hilog.info(DOMAIN, TAG, 'EntryAbility onBackground');
  }
}
