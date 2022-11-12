import React, { useState } from 'react';
import {
  Card,
  CardHeader,
  IconButton,
  Button,
  Autocomplete,
  TextField,
} from '@mui/material';
import { BankTransferDTO, IContacts } from '../types/bank';
import ContentCopyIcon from '@mui/icons-material/ContentCopy';
import { useAccountNumberValue, useBankBalanceValue, useContactsValue } from '../atoms/bank-atoms';
import NumberFormat from 'react-number-format';
import { styled } from '@mui/system';
import { useBankAPI } from '../hooks/useBankAPI'

const TransferArea = styled('div')({
  padding: 8,
  display: 'flex',
  flexDirection: 'column',
  gap: 12
});

const BankingPage = styled('div')({
  display: 'flex',
  flexDirection: 'column',
  justifyContent: 'space-between',
  height: '100%',
  padding: '1.5rem'
})

const Account = () => {
  const bankBalance = useBankBalanceValue();
  const accountNumber = useAccountNumberValue();
  const contacts = useContactsValue();
  const [transferAccount, setTransferAccount] = useState<IContacts | string>('');
  const [transferAmmount, setTransferAmmount] = useState('');
  const { transferMoney } = useBankAPI();

  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setTransferAmmount(event.target.value);
  };

  const canTransfer = () => {
    if (Number(transferAmmount) <= 0) return false;
    if (typeof transferAccount === 'string' && transferAccount.length <= 0) return false;
    if (typeof transferAccount !== 'string' && transferAccount === null) return false;
    return true;
  };

  const handleTransfer = () => {
    const data: BankTransferDTO = {
      amount: Number(transferAmmount),
      toAccount: transferAccount,
      transferType: typeof transferAccount !== 'string' ? 'contact' : 'accountNumber'
    }
    transferMoney(data) 
  }

  return (
    <BankingPage>
      <Card>
        <CardHeader
          action={
            <IconButton aria-label="copy">
              <ContentCopyIcon />
            </IconButton>
          }
          title={
            <NumberFormat
              value={bankBalance}
              prefix={'$'}
              thousandSeparator={true}
              displayType={'text'}
            />
          }
          subheader={accountNumber}
        />
      </Card>

      <TransferArea>
        <Autocomplete<IContacts, false, true, true> //mui sucks
          id="controllable-states-demo"
          getOptionLabel={(option) => (typeof option !== 'string' ? option.display : '')}
          options={contacts}
          freeSolo
          disableClearable
          onChange={(e, val) => setTransferAccount(val)}
          renderInput={(params) => (
            <TextField
              {...params}
              inputProps={{
                ...params.inputProps,
                onKeyDown: (e) => {
                  if (e.key === 'Enter') {
                    e.stopPropagation();
                  }
                },
              }}
              label="Transfer To"
              placeholder="Search contacts or enter account number"
              onChange={(e) => setTransferAccount(e.currentTarget.value)}
            />
          )}
        />

        <TextField
          id="amount"
          label="Transfer Amount"
          value={transferAmmount}
          onChange={handleChange}
          type="number"
        />

        <Button
          disabled={!canTransfer()}
          onClick={handleTransfer}
          variant="outlined"
        >
          Transfer
        </Button>
      </TransferArea>
    </BankingPage>
  );
};

export default Account;
