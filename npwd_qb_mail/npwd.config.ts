import App from './src/App';
import { MailIcon } from './icon';
import { theme } from './src/app.theme';

export const externalAppConfig = () => ({
  id: 'mail',
  nameLocale: 'Mail',
  color: '#fff',
  backgroundColor: '#333',
  path: '/mail',
  icon: MailIcon,
  app: App,
  theme: theme,
});

export default externalAppConfig;