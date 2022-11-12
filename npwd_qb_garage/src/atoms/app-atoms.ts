import { atom, useRecoilState } from "recoil";

const themeMode = atom({
	key: 'appThemeMode',
	default: false,
})

export const useThemeMode = () => useRecoilState(themeMode);
