// FIXME: Kafka publish failures are silently ignored
// If Kafka is unavailable, product updates aren't tracked
// Need dead letter queue or retry mechanism

// TODO: Implement event schema versioning
// Currently no version field in Kafka messages
// Will cause issues when we need to change message format

// TODO: Add batch publishing for bulk operations
// Publishing one message per product during bulk import is slow
// Batch publishing would improve throughput

// FIXME: No acknowledgment handling
// Don't verify that Kafka successfully received the message
// Could lose data during network issues

const { Kafka, Partitioners } = require("kafkajs");

let producer;

async function getProducer() {
  if (producer) {
    return producer;
  }

  const BROKER_URLS = (
    process.env.KAFKA_BOOTSTRAP_SERVERS || "localhost:9092"
  ).split(",");

  const kafka = new Kafka({
    clientId: "catalog-service",
    brokers: BROKER_URLS,
  });

  const p = kafka.producer({
    createPartitioner: Partitioners.LegacyPartitioner,
  });
  await p.connect();

  producer = p;
  return producer;
}

async function teardown() {
  if (producer) {
    await producer.disconnect();
  }
}

async function publishEvent(topic, event) {
  const producer = await getProducer();

  try {
    await producer.send({
      topic,
      messages: [{ value: JSON.stringify(event) }],
    });
  } catch (e) {
    console.error("Failed to publish event", e);
  }
}

module.exports = {
  publishEvent,
  teardown,
};
