import {
  List,
  ListItem,
  ListItemIcon,
  ListItemText,
  IconButton,
  Stack,
  Typography,
  Tooltip,
} from '@mui/material';
import React, { Fragment, useEffect } from 'react';
import { useBankBalanceValue, useInvoiceListValue } from '../atoms/bank-atoms';
import ReceiptIcon from '@mui/icons-material/Receipt';
import CheckCircleRoundedIcon from '@mui/icons-material/CheckCircleRounded';
import CancelRoundedIcon from '@mui/icons-material/CancelRounded';
import NumberFormat from 'react-number-format';
import { useNuiEvent } from 'react-fivem-hooks';
import { IInvoice } from '../types/bank';
import { useBankActions } from '../hooks/useBankActions';
import { useBankAPI } from '../hooks/useBankAPI';

const Billing = () => {
  const invoices = useInvoiceListValue();
  const { newInvoice } = useBankActions();
  const { declineInvoice, payInvoice } = useBankAPI();
  const bankBalance = useBankBalanceValue();
  
  const { data } = useNuiEvent<IInvoice>({ event: 'npwd:qb-banking:newInvoice' });

  useEffect(() => {
    if (data) {
      newInvoice(data);
    }
  }, [data]);

  const handleDeclineInvoice = (invoiceId: number) => {
    declineInvoice(invoiceId);
  };

  const handlePayInvoice = (invoice: IInvoice) => {
    payInvoice(invoice);
  };

  return (
    <List disablePadding>
      {invoices.map((invoice) => (
        <ListItem
          key={invoice.id}
          divider
          secondaryAction={
            <Stack direction="row">
              <Tooltip title="Pay">
                <IconButton
                  size="small"
                  aria-label="pay"
                  color="success"
                  onClick={() => handlePayInvoice(invoice)}
                  disabled={invoice.amount > bankBalance}
                >
                  <CheckCircleRoundedIcon />
                </IconButton>
              </Tooltip>
              <Tooltip title="Decline">
                <IconButton
                  size="small"
                  aria-label="decline"
                  color="secondary"
                  onClick={() => handleDeclineInvoice(invoice.id)}
                >
                  <CancelRoundedIcon />
                </IconButton>
              </Tooltip>
            </Stack>
          }
        >
          <ListItemIcon>
            <ReceiptIcon color="primary" />
          </ListItemIcon>
          <ListItemText
            primary={
              <Fragment>
                <Typography
                  sx={{ display: 'inline', textTransform: 'capitalize' }}
                  component="span"
                  variant="body2"
                  color="text.primary"
                >
                  {invoice.society}
                </Typography>
                <Typography
                  sx={{ display: 'inline', fontSize: '0.785rem', marginLeft: '1px' }}
                  component="span"
                  variant="body2"
                  color="text.secondary"
                >
                  {` (Sender: ${invoice.sender})`}
                </Typography>
              </Fragment>
            }
            secondary={
              <NumberFormat
                value={invoice.amount}
                prefix={'$'}
                thousandSeparator={true}
                displayType={'text'}
              />
            }
          />
        </ListItem>
      ))}
    </List>
  );
};

export default Billing;
