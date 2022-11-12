import { IContacts, IInvoice } from '../types/bank'

export const MockContacts: IContacts[] = [
  {
    id: 1,
    display: 'Rocko',
    number: '555-15196',
  },
  {
    id: 2,
    display: 'Taso',
    number: '215-8139',
    avatar: 'http://i.tasoagc.dev/i9Ig',
  },
  {
    id: 3,
    display: 'Chip',
    number: '603-275-8373',
    avatar: 'http://i.tasoagc.dev/2QYV',
  },
  {
    id: 4,
    display: 'Avarian',
    number: '444-4444',
  },
];

export const MockInvoices: IInvoice[] = [
  {
    id: 1,
    citizenid: "NSI72784",
    amount: 200,
    society: "mechanic",
    sender: "Sam",
    sendercitizenid: "PQS14529"
  },
  {
    id: 2,
    citizenid: "NSI72784",
    amount: 1200,
    society: "police",
    sender: "John",
    sendercitizenid: "DFS14529"
  }
];
