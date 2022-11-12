import { common, green } from '@mui/material/colors';
import { ThemeOptions } from '@mui/material';

export const APP_PRIMARY_COLOR = green[500];
export const APP_TEXT_COLOR = common.white;

export const theme: ThemeOptions = {
	palette: {
		primary: {
			main: APP_PRIMARY_COLOR,
			dark: green[700],
			light: green[300],
			contrastText: APP_TEXT_COLOR,
		},
		secondary: {
			main: '#d32f2f',
			light: '#eb4242',
			dark: '#941212',
			contrastText: APP_TEXT_COLOR,
		},
		success: {
			main: '#2196f3',
			contrastText: APP_TEXT_COLOR,
		},
	},
};