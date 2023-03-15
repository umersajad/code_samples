import { TestProvider } from "testHelpers/testProviders";
import { GET_MONEY_TRANSFERS_GQL } from "graphql/queries";
import { MOCK_TRANSFER_DATA } from "testHelpers/mockData";
import { Transactions } from "./Transactions";

export default {
  component: Transactions,
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
    <Transactions {...args} />
  </TestProvider>
);

export const Default = Template.bind({});
Default.parameters = {
  apolloClient: {
    mocks: mocks,
  },
};
