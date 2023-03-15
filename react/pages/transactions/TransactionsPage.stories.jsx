import { TransactionsPage } from "./TransactionsPage";
import { TestProvider } from "testHelpers/testProviders";
import { MOCK_TRANSFER_DATA } from "testHelpers/mockData";
import { GET_MONEY_TRANSFERS_GQL } from "graphql/queries";

export default {
  component: TransactionsPage,
};

const mocks = [
  {
    request: {
      query: GET_MONEY_TRANSFERS_GQL,
      variables: {
        pageNo: 0,
        pageSize: 100,
      },
    },
    result: {
      data: {
        moneyTransfers: {
          content: MOCK_TRANSFER_DATA,
        },
      },
    },
  },
];
const Template = (args) => (
  <TestProvider apolloMocks={mocks}>
    <TransactionsPage {...args} />
  </TestProvider>
);

export const Default = Template.bind({});
Default.parameters = {
  apolloClient: {
    mocks: mocks,
  },
};
