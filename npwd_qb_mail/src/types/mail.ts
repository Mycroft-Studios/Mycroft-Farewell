export interface Mail {
    sender: string;
    subject: string;
    message: string;
    mailid: number;
    read: number;
    date: number;
    button?: buttonContentInt;
}

export interface buttonContentInt {
    buttonEvent: string;
    enabled: boolean;
    buttonData:{
    dealer: string;
    itemData: {
        minrep: number;
        item: string;
    };
    amount: number;
    locationLabel: string;
    coords: {
        x: number;
        y: number;
        z: number;
    };
    }
  }
  