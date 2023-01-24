import ballerinax/exchangerates;
import ballerina/log;
import ballerina/http;
import ballerina/time;

configurable string exchangeRateAPIKey = ?;

type PricingInfo record {
    string currencyCode;
    decimal amount;
    string validUntil;
};

# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {

    resource function get convert(string target = "AUD", string base = "USD", decimal amount = 1) returns PricingInfo|error {

        log:printInfo("new conversion request", targetCur = target, amount = amount, baseCur = base);

        exchangerates:Client exchangeratesEp = check new ();
        exchangerates:CurrencyExchangeInfomation getExchangeRateForResponse = check exchangeratesEp->getExchangeRateFor(apikey = exchangeRateAPIKey, baseCurrency = base);
    
        decimal rate = <decimal>getExchangeRateForResponse.conversion_rates[target];

        time:Utc validUntil = time:utcAddSeconds(time:utcNow(), 3600 * 60);


        PricingInfo pricingInfo = {
            currencyCode: target,
            amount: amount * rate,
            validUntil: time:utcToString(validUntil)   
        };

        return pricingInfo;
    }
}
