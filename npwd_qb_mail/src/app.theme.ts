import { common, red, orange } from '@mui/material/colors';
import { ThemeOptions } from '@mui/material';

export const MAIL_APP_PRIMARY_COLOR = orange[500];
export const MAIL_APP_TEXT_COLOR = common.white;

export const theme: ThemeOptions = {
  palette: {
    primary: {
      main: MAIL_APP_PRIMARY_COLOR,
      dark: orange[900],
      light: orange[500],
      contrastText: MAIL_APP_TEXT_COLOR,
    },
    secondary: {
      main: orange[500],
      dark: orange[900],
      light: orange[500],
      contrastText: MAIL_APP_TEXT_COLOR,
    },
  },
};
