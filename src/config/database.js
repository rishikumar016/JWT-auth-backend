import config from "./config.js";
import mongoose from "mongoose";
import dns from "dns";

// Use public DNS resolvers so mongodb+srv:// SRV lookups work even when
// the system DNS is blocked/refused (common on VPN or restricted networks).
dns.setServers(["8.8.8.8", "1.1.1.1"]);

const connectDB = async () => {
  try {
    await mongoose.connect(config.MONGODB_URI);
    console.log(`Database Connected successfully`);
  } catch (error) {
    console.error(`Database connection failed: ${error.message}`);
    process.exit(1);
  }
};

mongoose.connection.on("error", (err) => {
  console.error(`Database error: ${err.message}`);
});

export default connectDB;
