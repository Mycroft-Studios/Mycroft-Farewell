import App from './src/App';
import { AppIcon } from './icon';
import { APP_PRIMARY_COLOR } from './src/app.theme'

const defaultLanguage = 'en';
const localizedAppName = {
  en: 'Banking',
};

interface Settings {
  language: 'en';
}

export const path = '/banking';
export default (settings: Settings) => ({
  id: 'BANKING',
  path,
  nameLocale: localizedAppName[settings?.language ?? defaultLanguage],
  color: '#fff',
  backgroundColor: APP_PRIMARY_COLOR,
  icon: AppIcon,
  app: App,
});
