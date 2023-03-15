import { LOCALE } from "locales";
import { FormattedMessage } from "react-intl";

export const TRANSACTIONS_STATES = Object.freeze({
  all: "",
  contribution: "CONTRIBUTION",
  distribution: "DISTRIBUTION",
  investment: "INVESTMENT",
});

export const HEADER_ITEMS = Object.freeze([
  {
    sortKey: "data1",
    label: <FormattedMessage id={LOCALE.transactions.date} />,
    sortable: false,
    alignHead: "left",
    headerStyle: {
      paddingLeft: "2rem !important",
    },
  },
  {
    sortKey: "data2",
    label: <FormattedMessage id={LOCALE.transactions.investment} />,
    sortable: false,
    alignHead: "left",
  },
  {
    sortKey: "data3",
    label: <FormattedMessage id={LOCALE.transactions.type} />,
    sortable: false,
    alignHead: "left",
  },
  {
    sortKey: "data3",
    label: <FormattedMessage id={LOCALE.transactions.distributionMemo} />,
    sortable: false,
    alignHead: "left",
  },
  {
    sortKey: "data4",
    label: <FormattedMessage id={LOCALE.transactions.amount} />,
    sortable: false,
    alignHead: "right",
    headerStyle: {
      paddingRight: "3rem !important",
    },
  },
]);

export const filterOptions = [
  {
    label: <FormattedMessage id={LOCALE.transactions.all} />,
    value: TRANSACTIONS_STATES.all,
  },
  {
    label: <FormattedMessage id={LOCALE.transactions.contribution} />,
    value: TRANSACTIONS_STATES.contribution,
  },
  {
    label: <FormattedMessage id={LOCALE.transactions.distribution} />,
    value: TRANSACTIONS_STATES.distribution,
  },
];
