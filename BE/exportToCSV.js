require('dotenv').config();
const mongoose = require('mongoose');
const fs = require('fs');
const Service = require('./models/Service');
const User = require('./models/User');
const Booking = require('./models/Booking');
const Itinerary = require('./models/Itinerary');

async function exportToCSV() {
  try {
    await mongoose.connect(process.env.MONGO_URI);
    console.log('✅ Connected to MongoDB');

    // Export Services
    console.log('\n📊 Exporting Services...');
    const services = await Service.find().lean();
    const serviceCSV = [
      'serviceId;title;category;location;price;rating;description;images;features;availability',
      ...services.map(s => 
        `${s.serviceId};${s.title};${s.category};${JSON.stringify(s.location)};${s.price};${s.rating};${s.description};${JSON.stringify(s.images)};${JSON.stringify(s.features)};${s.availability}`
      )
    ].join('\n');
    fs.writeFileSync('./data/service.csv', serviceCSV, 'utf8');
    console.log(`✅ Exported ${services.length} services to data/service.csv`);

    // Export Users
    console.log('\n📊 Exporting Users...');
    const users = await User.find().select('-password').lean();
    const userCSV = [
      'userId;name;email;role;interests;budgetRange;contactPhone;avatarUrl;createdAt',
      ...users.map(u => 
        `${u.userId};${u.name};${u.email};${u.role};${JSON.stringify(u.interests || [])};${u.budgetRange || ''};${u.contactPhone || ''};${u.avatarUrl || ''};${u.createdAt}`
      )
    ].join('\n');
    fs.writeFileSync('./data/user.csv', userCSV, 'utf8');
    console.log(`✅ Exported ${users.length} users to data/user.csv`);

    // Export Bookings
    console.log('\n📊 Exporting Bookings...');
    const bookings = await Booking.find().lean();
    const bookingCSV = [
      'bookingId;userId;serviceId;startDate;endDate;totalPrice;status;createdAt',
      ...bookings.map(b => 
        `${b.bookingId};${b.userId};${b.serviceId};${b.startDate};${b.endDate};${b.totalPrice};${b.status};${b.createdAt}`
      )
    ].join('\n');
    fs.writeFileSync('./data/booking.csv', bookingCSV, 'utf8');
    console.log(`✅ Exported ${bookings.length} bookings to data/booking.csv`);

    // Export Itineraries
    console.log('\n📊 Exporting Itineraries...');
    const itineraries = await Itinerary.find().lean();
    const itineraryCSV = [
      'itineraryId;userId;destination;travelProfile;schedule;isSaved;createdAt',
      ...itineraries.map(i => 
        `${i.itineraryId};${i.userId};${i.destination};${JSON.stringify(i.travelProfile)};${JSON.stringify(i.schedule)};${i.isSaved};${i.createdAt}`
      )
    ].join('\n');
    fs.writeFileSync('./data/itinerary.csv', itineraryCSV, 'utf8');
    console.log(`✅ Exported ${itineraries.length} itineraries to data/itinerary.csv`);

    console.log('\n✅ All data exported successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error:', error);
    process.exit(1);
  }
}

exportToCSV();
