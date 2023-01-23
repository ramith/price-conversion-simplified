import ballerinax/exchangerates;
import ballerina/http;
import ballerina/time;

type PricingInfo record {
    string currencyCode;
    decimal amount;
    string validUntil;
};


configurable string exchangeratesAPIKey = ?;

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get convert(string base, decimal amount, string target) returns PricingInfo|error? {

        exchangerates:Client exchangeratesEp = check new ();
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check exchangeratesEp->getExchangeRateFor(apikey = exchangeratesAPIKey, baseCurrency = base);

        decimal rate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        time:Utc validUntil = time:utcAddSeconds(time:utcNow(), 3600 * 60);

        PricingInfo convertedPrice = {
            currencyCode: target,
            amount: amount * rate,
            validUntil: time:utcToString(validUntil)
        };
        
        return convertedPrice;

    }
}
