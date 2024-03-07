--Standardize Date Format

select SaleDate, convert(datetime, saledate) from dbo.NashvilleHousing


-- Sometimes, the following code does't work well to change data types.
update dbo.NashvilleHousing
set SaleDate = CONVERT(datetime, saledate)
select saledate from dbo.NashvilleHousing


-- Alternatively, the following method is another way to change the data types.
ALTER TABLE dbo.Nashvillehousing
add saledateconverted datetime
update dbo.NashvilleHousing
set saledateconverted = CONVERT(datetime, saledate)
select SaleDate, saledateconverted from dbo.NashvilleHousing


select PropertyAddress from dbo.NashvilleHousing
where PropertyAddress is null
--------------------------------------------------------------------------------------------------------------------------
-- count the total records which have null values in PropertyAddress column.
select count(*) from dbo.NashvilleHousing
where PropertyAddress is null

---------------------------------------------------------------------------------------------------------------------------

--In this database, some two records have same ParceID and same PropertyAddress, some do not. We can join function 
-- to join itself to look at it. 
-- To populate property address data
select PropertyAddress from dbo.NashvilleHousing
select * from dbo.NashvilleHousing

select * from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a
join dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null

------------------------------------------------------------------------------------------------------------------------------
--Breaking out Address into individual column (city, county, state)
select PropertyAddress
from dbo.NashvilleHousing

select 
SUBSTRING(propertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as ADDRESS, CHARINDEX(',', PropertyAddress),
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as city
from dbo.NashvilleHousing

-- Add the two new splited columns to the dataset
ALTER Table dbo.NashvilleHousing
ADD splitedAddress nvarchar(255)

ALTER table dbo.NashvilleHousing
ADD splitedcity nvarchar(255)

select * from dbo.NashvilleHousing

update dbo.nashvilleHousing
set splitedAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

update dbo.NashvilleHousing
set splitedcity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress)+1, len(PropertyAddress))

--Breake out the owneraddress column 
select OwnerAddress
from dbo.NashvilleHousing

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from dbo.NashvilleHousing
--Add these columns into dataset

ALTER TABLE DBO.NASHVILLEHOUSING
ADD OWNERSPLITEDADDRESS NVARCHAR(255)

--------------------------------------------------------------------------------------------------------------------------------------
--Change Y and N to Yes and No in 'SoldasVacant'
select distinct(SoldAsVacant), COUNT(soldasvacant)
from dbo.NashvilleHousing
group by SoldAsVacant

select soldasvacant,
case 
when SoldAsVacant = '1' then 'Yes'
else 'No'
end
from dbo.NashvilleHousing

update dbo.NashvilleHousing
set 
SoldAsVacant = case when SoldAsVacant = '1' then 'Yes'
else 'No'
end
----------------------------------------------------------------------------------------------------------------------------------
--Remove duplicate
select *,
row_number() over (partition by ParcelID,
                                PropertyAddress,
								Saledate,
								SalePrice,
								Legalreference
								order by uniqueID)
								as row_num
from dbo.NashvilleHousing
--Create a temp table 
with duolicaterowCTE as(
select *,
row_number() over (partition by ParcelID,
                                PropertyAddress,
								Saledate,
								SalePrice,
								Legalreference
								order by uniqueID)
								as row_num
from dbo.NashvilleHousing
)
--select row_num
--from duolicaterowCTE
delete 
from duolicaterowCTE
where row_num > 1

---------------------------------------------------------------------------------------------------------------------------------------------
-- Drop columns
select * from dbo.NashvilleHousing
alter table dbo.nashvillehousing
drop column Propertyaddress, Owneraddress
